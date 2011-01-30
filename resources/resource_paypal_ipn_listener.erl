%% @author Alain O'Dea <alain.odea@gmail.com>
%% @copyright 2011 Lloyd R. Prentice
%% @date 2011-01-21
%% @doc Webmachine-based PayPal IPN Listener
%% The role of the resource_paypal_ipn_listener is to receive IPNs from
%% PayPal, verify them, generate Download Pages and email links to the buyer
%% @end

%% Copyright 2011 Lloyd R. Prentice
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%% 
%%     http://www.apache.org/licenses/LICENSE-2.0
%% 
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.

-module(resource_paypal_ipn_listener).
-author("Alain O'Dea <alain.odea@gmail.com>").
-export([init/1]).
%% resource functions
-export([service_available/2,
         allowed_methods/2,
         resource_exists/2,
         process_post/2,
         finish_request/2]).
%% representation providers
-export([to_html/2]).

-include_lib("webmachine_resource.hrl").
-include_lib("zotonic.hrl").

init(DispatchArgs) ->
    {ok, DispatchArgs}.

service_available(ReqData, DispatchArgs) when is_list(DispatchArgs) ->
    Context  = z_context:new(ReqData, ?MODULE),
    Context1 = z_context:set(DispatchArgs, Context),
    ?WM_REPLY(true, Context1).

%% only POST requests are valid for PayPal IPN
allowed_methods(ReqData, Context) ->
    {['POST'], ReqData, Context}.

resource_exists(ReqData, Context) ->
    {IPNBody, ReqData1} = wrq:req_body(ReqData),
    Context1 = z_context:set_reqdata(ReqData1, Context),
    PayPalAPI = case m_config:get_value(mod_paypal, sandbox_mode, Context1) of
        undefined -> "https://www.paypal.com/cgi-bin/webscr";
        _ -> "https://www.sandbox.paypal.com/cgi-bin/webscr"
    end,
    IPNVerificationBody = [<<"?cmd=_notify-validate&">>, IPNBody],
    VerificationUrl = PayPalAPI ++ binary_to_list(iolist_to_binary(
                       IPNVerificationBody)),
    case httpc:request(VerificationUrl) of
        {ok, {{"HTTP/1.1",200,"OK"}, _, "VERIFIED"}} ->
            % verified valid IPN
            ?WM_REPLY(true, Context1);
        _ ->
            % fraudulent or malformed IPN, play dead to hide from hackers
            ?WM_REPLY(false, Context1)
    end.

process_post(ReqData, Context) ->
    Context1 = ?WM_REQ(ReqData, Context),
    ContextQs = z_context:ensure_qs(Context1),
    "Completed" = z_context:get_q("payment_status", ContextQs),

    % The transaction ID needs to be checked in case this is a duplicate POST
    % from PayPal (which is possible)
    TransactionId = z_context:get_q("txn_id", ContextQs),

    % verify that the receiver_email matches the config (spoof protection)
    ReceiverEmail = m_config:get_value(mod_paypal, receiver_email, ContextQs),
    case list_to_binary(z_context:get_q("receiver_email", ContextQs)) of
        ReceiverEmail -> ok,
        WrongReceiver -> ?ERROR("Bad receiver_email: ~p", [WrongReceiver])
    end,

    % use id of Book RSC as the item number
    % need to verify that it exists
    ItemNumber = list_to_integer(z_context:get_q("item_number1", ContextQs)),
    
    DownloadLink = store_download_rsc(TransactionId, ItemNumber, Context),

    PayerEmail = z_context:get_q("payer_email", ContextQs),
    % send payer download link by email
    send_download_link(PayerEmail, DownloadLink, Context),
    ?WM_REPLY(true, ContextQs).

store_download_rsc(TransactionId, BookId, Context) ->
    % somehow mark the txn_id so that de-duplication checks work
    DownloadCategoryId = m_category:name_to_id_check(download, Context),
    %#search_result{result=Result1} = z_search:search({download_transaction_id, [{cat, DownloadCategoryId}]}, Context),
    RandomId = base64:encode_to_string(crypto:rand_bytes(40)),
    BasePath = z_context:get(base_path, Context),
    RandomPagePath = z_utils:url_path_encode("/" ++ BasePath ++ "/" ++ RandomId),
    Props = [{category_id, DownloadCategoryId},
             {is_published, false},
             {transaction_id, TransactionId},
             {page_path, RandomPagePath}],

    F = fun(Ctx) ->
        % add a Download RSC to Zotonic
        {ok, DownloadId} = m_rsc:insert(Props, Ctx),
        % add a page connection to the RSC to the Book that was purchased
        % FIXME: this crashes the transaction with a rollback
        {ok, _} = m_edge:insert(DownloadId, depiction, BookId, Ctx)
    end,
    AdminContext = z_acl:sudo(Context),

    {ok, _} = z_db:transaction(F, AdminContext),

    % return the Page URL of the Download RSC
    ["http://", m_site:get(hostname, Context), RandomPagePath].

send_download_link(PayerEmail, DownloadLink, Context) ->
    Vars = [{download_link, DownloadLink},
            {first_name, z_context:get_q("first_name", Context)},
            {last_name, z_context:get_q("last_name", Context)}],
    z_email:sendq_render(PayerEmail,
                         "_email_download_html.tpl",
                         "_email_download_text.tpl",
                         Vars, Context).

to_html(ReqData, Context) ->
    {"ACCEPT", ReqData, Context}.

finish_request(ReqData, Context) ->
    {true, ReqData, Context}.

<!--
       Licensed to the Apache Software Foundation (ASF) under one
       or more contributor license agreements.  See the NOTICE file
       distributed with this work for additional information
       regarding copyright ownership.  The ASF licenses this file
       to you under the Apache License, Version 2.0 (the
       "License"); you may not use this file except in compliance
       with the License.  You may obtain a copy of the License at

         http://www.apache.org/licenses/LICENSE-2.0

       Unless required by applicable law or agreed to in writing,
       software distributed under the License is distributed on an
       "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
       KIND, either express or implied.  See the License for the
       specific language governing permissions and limitations
       under the License.
-->
{# Show the edit fields to edit the product's link to PayPal #}
{% with m.rsc[id] as r %}
<div class="item-wrapper">
	<h3 class="above-item clearfix do_blockminifier { minifiedOnInit: false }">
		<span class="title">{_ PayPal _}</span>
		<span class="arrow">{_ make smaller _}</span>
	</h3>
	<div class="item clearfix">
		<div class="admin-form form-item">
			<div class="notification notice">
				{_ Link this product to PayPal. _} <a href="javascript:void(0)" class="do_dialog {title: '{_ Help about linking product to PayPal. _}', text: '{_ The hosted button&zwnj; ID should match an ID from <a style=&quot;color: grey&quot; target=&quot;_blank&quot; href=&quot;https://www.paypal.com/ca/cgi-bin/webscr?cmd=_button-management&quot;>My Saved Buttons</a> in your PayPal account.&zwnj;. _}', width: '450px'}">{_ Need more help? _}</a>
{#
    '&zwnj;' is a hack workaround for Chrome's handling of class params
    'color: grey' is a hack workaround for black text links in dialogs
#}
			</div>
			<fieldset>
				<div class="form-item">
					<label>{_ Hosted button ID _}</label>
					<input id="paypal_button_id" type="text" name="paypal_button_id" value="{{ r.paypal_button_id }}" />
				</div>
			</fieldset>
		</div>
	</div>
</div>
{% endwith %}
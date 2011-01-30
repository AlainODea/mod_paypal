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
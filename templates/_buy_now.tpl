{# Show a PayPal Add To Cart button if there is a button ID set #}
{% with m.rsc[id] as r %}
	{% if r.paypal_button_id %}
	<form class="paypal" target="paypal" action="https://www.paypal.com/cgi-bin/webscr" method="post">
		<input type="hidden" name="cmd" value="_s-xclick">
		<input type="hidden" name="hosted_button_id" value="{{ m.rsc[id].paypal_button_id }}">
		<input type="image" src="https://www.paypal.com/en_US/i/btn/btn_buynow_LG.gif" border="0" name="submit" alt="PayPal - The safer, easier way to pay online!">
		<img alt="" border="0" src="https://www.paypal.com/en_US/i/scr/pixel.gif" width="1" height="1">
	</form>
	{% endif %}
{% endwith %}
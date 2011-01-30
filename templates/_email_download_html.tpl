{% extends "email_base.tpl" %}

{% block title %}{_ eBook Download from _} {{ m.config.site.title.value|default:m.site.hostname }}{% endblock %}

{% block body %}
<p>{_ Hi _} {{ first_name|escape }},</p>

<p>{_ Thank you for your purchase. _}</p>

<p><a href="{{ download_link }}">{_ Download your eBook now! _}</a></p>
{% endblock %}

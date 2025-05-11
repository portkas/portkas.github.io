{% extends '_layout.swig' %}
{% block content %}
  <div class="cover-container">
    <h1 class="cover-title">{{ page.title }}</h1>
    {% if page.cover.caption %}
      <p class="cover-caption">{{ page.cover.caption }}</p>
    {% endif %}
  </div>
{% endblock %}
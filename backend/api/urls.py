
from django.urls import path, include

from rest_framework import routers
from rest_framework.authtoken import views as authtoken_views

from . import views as views

# Routers provide an easy way of automatically determining the URL conf.
user_router = routers.DefaultRouter()
user_router.register(r'users', views.UserViewSet)

nft_router = routers.DefaultRouter()

urlpatterns = [
    path('', include(user_router.urls)),
    path('auth-token', views.CustomAuthToken.as_view(), name='auth_token'),
]
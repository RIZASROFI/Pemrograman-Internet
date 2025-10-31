from django.contrib import admin
from django.urls import path, include

from accounts import views as accounts_views
from django.shortcuts import redirect
from django.contrib.auth.decorators import login_required


# View untuk root path
def root_view(request):
    if request.user.is_authenticated:
        return redirect('dashboard:home')
    return redirect('login')

urlpatterns = [
    path('', root_view, name='root'),
    path('admin/', admin.site.urls),
    path('register/', accounts_views.register, name='register'),
    path('login/', accounts_views.login_view, name='login'),
    path('logout/', accounts_views.logout_view, name='logout'),
    path('dashboard/', include('dashboard.urls')),
]

from django.shortcuts import render, redirect
from django.contrib.auth import authenticate, login, logout
from django.contrib import messages
from .forms import RegisterForm
import logging

logger = logging.getLogger(__name__)



def register(request):
    if request.method == 'POST':
        form = RegisterForm(request.POST)
        if form.is_valid():
            form.save()
            messages.success(request, 'Akun berhasil dibuat! Silakan login menggunakan username dan password yang baru didaftarkan.')
            return redirect('login')
        else:
            messages.error(request, 'Registrasi gagal. Silakan periksa data yang Anda masukkan.')
    else:
        form = RegisterForm()
    return render(request, 'accounts/register.html', {'form': form})



def login_view(request):
    if request.method == 'POST':
        username = request.POST.get('username')
        password = request.POST.get('password')
        user = authenticate(request, username=username, password=password)
        if user is not None:
            login(request, user)
            messages.success(request, f'Selamat datang, {username}! Anda berhasil login.')
            return redirect('dashboard:home')
        else:
            logger.debug(f'Login failed for username: {username}')
            messages.error(request, 'Username atau password salah. Silakan coba lagi.')
    return render(request, 'accounts/login.html')


def logout_view(request):
    logout(request)
    return redirect('login')

from django import forms
from django.contrib.auth.models import User
from django.contrib.auth.forms import UserCreationForm
from django.core.validators import RegexValidator

class RegisterForm(UserCreationForm):
    email = forms.EmailField(required=True)
    username = forms.CharField(
        max_length=150,
        validators=[
            RegexValidator(
                regex=r'^[a-zA-Z0-9 @.+-_]+$',
                message='Username hanya boleh berisi huruf, angka, spasi, dan karakter @/./+/-/_.',
                code='invalid_username'
            )
        ]
    )

    class Meta:
        model = User
        fields = ('username', 'email', 'password1', 'password2')

    def save(self, commit=True):
        user = super().save(commit=False)
        user.email = self.cleaned_data['email']
        if commit:
            user.save()
        return user

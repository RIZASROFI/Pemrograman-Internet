from django.db import models

class Supplier(models.Model):
    id = models.CharField(max_length=50, primary_key=True, verbose_name="ID")
    name = models.CharField(max_length=100, verbose_name="Nama")
    contact = models.CharField(max_length=50, verbose_name="Kontak")
    email = models.EmailField(verbose_name="Email")
    city = models.CharField(max_length=100, verbose_name="Kota")
    address = models.TextField(verbose_name="Alamat Pemasok")

    def __str__(self):
        return self.name

    class Meta:
        verbose_name = "Pemasok"
        verbose_name_plural = "Pemasok"

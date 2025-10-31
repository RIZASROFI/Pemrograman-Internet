from django import forms
from .models import Supplier

class AddInventoryItemForm(forms.Form):
    id_item = forms.CharField(label='ID Item', max_length=100, required=True)
    jenis_item = forms.CharField(label='Jenis Item', max_length=100, required=True)
    kategori_item = forms.CharField(label='Kategori Item', max_length=100, required=True)
    subkategori_item = forms.CharField(label='Subkategori Item', max_length=100, required=True)
    nama_item = forms.CharField(label='Nama Item', max_length=100, required=True)
    tingkat_pemesanan_ulang = forms.IntegerField(label='Tingkat Pemesanan Ulang', required=True)

class AddSupplierForm(forms.ModelForm):
    class Meta:
        model = Supplier
        fields = ['id', 'name', 'contact', 'email', 'city', 'address']
        labels = {
            'id': 'ID',
            'name': 'Nama',
            'contact': 'Kontak',
            'email': 'Email',
            'city': 'Kota',
            'address': 'Alamat Pemasok',
        }

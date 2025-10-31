from django.urls import path
from . import views

app_name = 'dashboard'

urlpatterns = [
    path('', views.home, name='home'),
    path('inventory/', views.inventory, name='inventory'),
    path('inventory/add-item/', views.add_inventory_item, name='add_inventory_item'),
    path('inventory/add-item-type/', views.add_item_type, name='add_item_type'),
    path('inventory/add-item-simple/', views.add_item, name='add_item'),
    path('inventory/categories/', views.manage_categories, name='manage_categories'),
    path('inventory/edit-item/', views.edit_inventory_item, name='edit_inventory_item'),
    path('suppliers/', views.suppliers, name='suppliers'),
    path('suppliers/add/', views.add_supplier, name='add_supplier'),
    path('suppliers/edit/', views.edit_supplier, name='edit_supplier'),
    path('suppliers/delete/', views.delete_supplier, name='delete_supplier'),
]

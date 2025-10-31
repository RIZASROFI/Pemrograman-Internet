from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.http import JsonResponse
import json
from .forms import AddInventoryItemForm, AddSupplierForm
from .models import Supplier


@login_required
def home(request):
    # Data untuk kartu ringkasan
    new_orders_count = 5
    total_spending = "1.250.000"
    products_viewed = 27
    wishlist_count = 3

    # Data untuk ringkasan persediaan
    low_stock_count = 3
    best_selling_items = [
        {"name": "Pulpen Pilot", "sold": 150},
        {"name": "Buku Tulis", "sold": 120},
        {"name": "Kertas A4", "sold": 100},
    ]
    total_inventory_value = "5.000.000"

    recent_activities = [
        {"icon_bg": "warning-light", "icon": "fa-exclamation-triangle", "title": "Stok 'Kertas A4' rendah", "time": "2 jam lalu"},
        {"icon_bg": "success-light", "icon": "fa-plus", "title": "Barang 'Pulpen Pilot' ditambahkan", "time": "kemarin"},
        {"icon_bg": "info-light", "icon": "fa-shopping-cart", "title": "Penjualan 'Buku Tulis' tercatat", "time": "2 hari lalu"},
    ]



    context = {
        "new_orders_count": new_orders_count,
        "total_spending": total_spending,
        "products_viewed": products_viewed,
        "wishlist_count": wishlist_count,
        "low_stock_count": low_stock_count,
        "best_selling_items": best_selling_items,
        "total_inventory_value": total_inventory_value,
        "recent_activities": recent_activities,
        "page_icon": "fas fa-tachometer-alt",
        "page_title": "Dashboard",
    }
    return render(request, "dashboard/dashboard.html", context)


@login_required
def inventory(request):
    # Data dummy inventori agar mirip halaman inventory (dengan filter sederhana)
    items = [
        {"name": "Pulpen Pilot", "sku": "PL-001", "category": "Alat Tulis", "stock": 120, "min_stock": 20, "unit": "pcs", "buy_price": 2500, "sell_price": 4000, "status": "Aktif"},
        {"name": "Buku Tulis", "sku": "BK-002", "category": "Alat Tulis", "stock": 80, "min_stock": 15, "unit": "pcs", "buy_price": 4000, "sell_price": 6000, "status": "Aktif"},
        {"name": "Kertas A4", "sku": "KT-003", "category": "Kertas", "stock": 35, "min_stock": 50, "unit": "rim", "buy_price": 35000, "sell_price": 45000, "status": "Aktif"},
        {"name": "Tinta Printer", "sku": "TN-004", "category": "Aksesoris", "stock": 10, "min_stock": 10, "unit": "botol", "buy_price": 80000, "sell_price": 95000, "status": "Nonaktif"},
        {"name": "Spidol Boardmarker", "sku": "SP-005", "category": "Alat Tulis", "stock": 12, "min_stock": 15, "unit": "pcs", "buy_price": 7000, "sell_price": 9500, "status": "Aktif"},
        {"name": "Amplop Coklat", "sku": "AM-006", "category": "Kertas", "stock": 0, "min_stock": 10, "unit": "pcs", "buy_price": 500, "sell_price": 1000, "status": "Habis"},
    ]

    q = (request.GET.get("q") or "").lower()
    category = request.GET.get("category") or ""
    status = request.GET.get("status") or ""

    filtered = []
    for it in items:
        text = f"{it['name']} {it['sku']}".lower()
        match = True
        if q and q not in text:
            match = False
        if category and it["category"] != category:
            match = False
        if status and it["status"] != status:
            match = False
        if match:
            filtered.append(it)

    categories = sorted({it["category"] for it in items})
    statuses = ["Aktif", "Nonaktif", "Habis"]

    total_items = len(filtered)
    total_stock = sum(it["stock"] for it in filtered)
    low_stock_count = sum(1 for it in filtered if it["stock"] <= it["min_stock"])
    total_value = sum(it["stock"] * it["buy_price"] for it in filtered)

    context = {
        "items": filtered,
        "all_categories": categories,
        "all_statuses": statuses,
        "query": request.GET,
        "summary": {
            "total_items": total_items,
            "total_stock": total_stock,
            "low_stock": low_stock_count,
            "total_value": total_value,
        },
        "page_icon": "fas fa-boxes-stacked",
        "page_title": "Persediaan",
    }
    return render(request, "dashboard/inventory.html", context)


@login_required
def add_inventory_item(request):
    if request.method == 'POST':
        form = AddInventoryItemForm(request.POST)
        if form.is_valid():
            # Dummy handling: print data and show success message
            print("New Inventory Item:", form.cleaned_data)
            messages.success(request, 'Item inventaris berhasil ditambahkan!')
            return JsonResponse({'status': 'success'})
    return JsonResponse({'status': 'error'})  # For modal submission


@login_required
def add_item_type(request):
    if request.method == 'POST':
        # Dummy handling for simplicity
        item_type = request.POST.get('item_type')
        print("New Item Type:", item_type)
        messages.success(request, 'Jenis barang berhasil ditambahkan!')
        return redirect('dashboard:inventory')
    return JsonResponse({'status': 'success'})  # For modal submission


@login_required
def add_item(request):
    if request.method == 'POST':
        # Dummy handling for simplicity
        item_name = request.POST.get('item_name')
        print("New Item:", item_name)
        messages.success(request, 'Barang berhasil ditambahkan!')
        return redirect('dashboard:inventory')
    return JsonResponse({'status': 'success'})  # For modal submission


@login_required
def manage_categories(request):
    # Dummy categories list
    categories = ['Alat Tulis', 'Kertas', 'Aksesoris']
    if request.method == 'POST':
        new_category = request.POST.get('new_category')
        if new_category:
            categories.append(new_category)
            messages.success(request, 'Kategori berhasil ditambahkan!')
            return redirect('dashboard:manage_categories')
    return JsonResponse({'status': 'success'})  # For modal submission


@login_required
def edit_inventory_item(request):
    if request.method == 'POST':
        sku = request.POST.get('sku')
        name = request.POST.get('name')
        category = request.POST.get('category')
        stock = request.POST.get('stock')
        min_stock = request.POST.get('min_stock')
        unit = request.POST.get('unit')
        buy_price = request.POST.get('buy_price')
        sell_price = request.POST.get('sell_price')

        # Dummy update: print the data
        print(f"Updating item {sku}: {name}, {category}, {stock}, {min_stock}, {unit}, {buy_price}, {sell_price}")
        messages.success(request, 'Item berhasil diperbarui!')
        return JsonResponse({'status': 'success'})
    return JsonResponse({'status': 'error'})

@login_required
def suppliers(request):
    suppliers = Supplier.objects.all()
    context = {
        'suppliers': suppliers,
        'page_icon': 'fas fa-truck-field',
        'page_title': 'Pemasok',
    }
    return render(request, 'dashboard/suppliers.html', context)

@login_required
def add_supplier(request):
    if request.method == 'POST':
        form = AddSupplierForm(request.POST)
        if form.is_valid():
            form.save()
            messages.success(request, 'Pemasok berhasil ditambahkan!')
            return JsonResponse({'status': 'success'})
        else:
            return JsonResponse({'status': 'error', 'errors': form.errors})
    return JsonResponse({'status': 'error'})

@login_required
def edit_supplier(request):
    if request.method == 'POST':
        supplier_id = request.POST.get('id')
        try:
            supplier = Supplier.objects.get(id=supplier_id)
            form = AddSupplierForm(request.POST, instance=supplier)
            if form.is_valid():
                form.save()
                messages.success(request, 'Pemasok berhasil diperbarui!')
                return JsonResponse({'status': 'success'})
            else:
                return JsonResponse({'status': 'error', 'errors': form.errors})
        except Supplier.DoesNotExist:
            return JsonResponse({'status': 'error', 'message': 'Pemasok tidak ditemukan'})
    return JsonResponse({'status': 'error'})

@login_required
def delete_supplier(request):
    if request.method == 'POST':
        supplier_id = request.POST.get('id')
        try:
            supplier = Supplier.objects.get(id=supplier_id)
            supplier.delete()
            messages.success(request, 'Pemasok berhasil dihapus!')
            return JsonResponse({'status': 'success'})
        except Supplier.DoesNotExist:
            return JsonResponse({'status': 'error', 'message': 'Pemasok tidak ditemukan'})
    return JsonResponse({'status': 'error'})

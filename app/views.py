# Create your views here.
from decimal import *

from django.http import HttpResponse, Http404, HttpResponseRedirect, HttpResponseBadRequest
from django.contrib.auth import authenticate, login, logout
from django.http import HttpResponseRedirect
from django.conf import settings

from django.contrib.auth.decorators import login_required

from payments.models import Customer
from annoying.decorators import render_to, ajax_request

from .forms import StripeTokenForm, ChargeForm, EmailForm


@render_to('index.html')
def index(request):
    if request.method == "POST":
       form = EmailForm(request.POST)
    else:
       form = EmailForm()
    return {"form": form}

def error(request):
    """for testing purposes"""
    raise Exception

def _404(request):
    """for testing purposes"""
    raise Http404

@ajax_request
@login_required
def create_customer(request):
    form = StripeTokenForm(request.POST)
    if not form.is_valid():
        return HttpResponseBadRequest()
    card = form.cleaned_data['id']
    customer = Customer.create(request.user, card=card, charge_immediately=False)
    return {}

@login_required
def charge_customer(request):
    customer = request.user.customer
    form = StripeTokenForm(request.POST)
    if not form.is_valid():
        return HttpResponseBadRequest()

    amount = form.cleaned_data['amount']
    customer.charge(amount, description="shorty_book")
    return HttpResponseRedirect("/")
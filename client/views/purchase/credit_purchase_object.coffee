creditPurchase =
  ORDER_STATE: 0
  _deps: {}
  amountInt: 0
  state: 0

  init: () ->
    @_deps['state'] = new Deps.Dependency

  # reactive getters and setters
  getState: () ->
    @_deps['state'].depend()
    return @state
  setState: (value) ->
    return if value is @state
    @state = value
    @_deps['state'].changed()

  # none reactive getters and setters
  getAmountInt: () ->
    return @amountInt
  setAmountInt: (value) ->
    @amountInt = value
  getVat: () ->
    return Math.round(@amountInt * 0.19)
  getTotal: () ->
    return @getAmountInt() + @getVat()


  getName: () ->
    return @name
  setName: (value) ->
    @name = value

  getAddress: (value) ->
    return @address
  setAddress: (value) ->
    @address = value


##############################
##### CREDIT PURCHASE TEMPLATE
##############################
Template.creditPurchaseObject.created = () ->
  # create our helper class when the main template is created
  # do not do this on rendered, because it could be called multiple
  # times
  creditPurchase.init()

Template.creditPurchaseObject.helpers({
  stateIsOrder: () ->
    # getState() is reactive
    return creditPurchase.getState() is creditPurchase.ORDER_STATE
})

##############################
##### ORDER FORM TEMPLATE
##############################
Template.orderFormObject.events({
  'submit form': (evt, tpl) ->
    evt.preventDefault()

    creditPurchase.setAmountInt(parseInt($('#amountIntObject').val()) * 100)
    creditPurchase.setName($('#nameObject').val())
    creditPurchase.setAddress($('#addressObject').val())

    # because setState() is reactive the orderConfirmation
    # template will be rendered automatically
    creditPurchase.setState(1)
})

Template.orderFormObject.helpers({
  amount: () -> return formatAmountInt(creditPurchase.getAmountInt())
  name: () -> return creditPurchase.getName()
  address: () -> return creditPurchase.getAddress()
})

##############################
##### ORDER CONFIRMATION TEMPLATE
##############################
Template.orderConfirmationObject.events({
  'click .edit': (evt, tpl) ->
    evt.preventDefault()
    creditPurchase.setState(0)
    return false
})

Template.orderConfirmationObject.helpers({
  amount: () -> return formatAmountInt(creditPurchase.getAmountInt())
  vat: () -> return formatAmountInt(creditPurchase.getVat())
  total: () -> return formatAmountInt(creditPurchase.getTotal())
  address: () -> return creditPurchase.getAddress()
})

##############################
##### HELPERS YOU COULD USE GLOBALLY
##############################
formatAmountInt = (amount) ->
  return amount/100
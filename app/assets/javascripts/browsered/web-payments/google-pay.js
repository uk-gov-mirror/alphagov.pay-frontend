'use strict'

const { getGooglePaymentsConfiguration, showErrorSummary } = require('./helpers')
const { email_collection_mode } = window.Charge


const processPayment = paymentData => {
  return fetch(`/web-payments-auth-request/google/${window.paymentDetails.chargeID}`, {
    method: 'POST',
    credentials: 'same-origin',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(paymentData)
  })
  .then(response => {
    if (response.status >= 200 && response.status < 300) {
      return response.json().then(data => {
        window.location.href = data.url
      })
    }
  })
  .catch(err => {
    showErrorSummary(i18n.fieldErrors.webPayments.failureTitle, i18n.fieldErrors.webPayments.failureBody)
    ga('send', 'event', 'Google Pay', 'Error', 'During authorisation/capture')
  })
}

const createGooglePaymentRequest = () => {
  const methodData = [{
    supportedMethods: 'https://google.com/pay',
    data: getGooglePaymentsConfiguration()
  }]

  const details = {
    total: {
      label: window.paymentDetails.description,
      amount: {
        currency: 'GBP',
        value: window.paymentDetails.amount
      }
    }
  }

  const options = {
    requestPayerEmail: email_collection_mode !== 'OFF',
    requestPayerName: true
  }

  return new PaymentRequest(methodData, details, options)
}

const googlePayNow = () => {
  createGooglePaymentRequest()
    .show()
    .then(response => {
      response.complete('success')
      processPayment(response)
    })
    .catch(dismissed => {
      ga('send', 'event', 'Google Pay', 'Aborted', 'by user')
    })
}

module.exports = {
  createGooglePaymentRequest,
  googlePayNow
}

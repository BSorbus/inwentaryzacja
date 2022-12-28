// This function is used to get error message for all ajax calls
function getErrorMessage(jqXHR, exception) {
  var msg = '';
  if (jqXHR.status === 0) {
    //msg = 'Not connect.\n Verify Network.';
    msg = 'Brak połączenia. Skontaktuj się z administratorem sieci';
  } else if (jqXHR.status == 401) {
    //window.location.reload();
    msg = '[401] - Sesja wygasła. Odśwież stronę' + jqXHR.responseText;
  } else if (jqXHR.status == 403) {
    msg = '[403] - Dostęp zabroniony' + jqXHR.responseText;
  } else if (jqXHR.status == 404) {
    //msg = 'Requested page not found. [404]';
    msg = '[404] - Nie znalazłem takiej strony.';
  } else if (jqXHR.status == 409) {
    msg = '[409] - Konflikt. Żądanie nie może być zrealizowane.';
  } else if (jqXHR.status == 500) {
    msg = '[500] - Internal Server Error [500].';
  } else if (exception === 'parsererror') {
    msg = 'Requested JSON parse failed.';
  } else if (exception === 'timeout') {
    msg = 'Time out error.';
  } else if (exception === 'abort') {
    msg = 'Ajax request aborted.';
  } else {
    msg = 'Uncaught Error.\n' + jqXHR.responseText;
  };

  if (jqXHR.responseText) {
    msg += '<br>' + jqXHR.responseText;
  };

  if (jqXHR.status) {
    toastr['error'](msg, 'Error ' + jqXHR.status, {timeOut: 15000});
  } else {
    toastr['error'](msg, 'Error', {timeOut: 15000});
  }

  //alert(msg)
};
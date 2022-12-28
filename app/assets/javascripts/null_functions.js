function isEmpty(val){
  return (val === undefined || val == null || val.length <= 0) ? true : false;
};

function ifNullToEmptyStr(val){
  return (val === undefined || val == null || val.length <= 0) ? "" : val;
};

function validateEmail(email) {
  var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
  return re.test(email);
};

var compare_dates = function(date1,date2){
  if (date1 > date2) 
  	return -1;
  else if (date1 < date2) 
  	return 1;
  else return 0; 
};

function validateExpiryDate(expiry_on, reminderBeforeExpiry) {
	var today = new Date();
	var expiryOn = expiry_on;

	today.setHours(0,0,0,0);
	expiryOn.setHours(0,0,0,0);


	 if ( reminderBeforeExpiry != 0 ) {
  	// console.log("...Add offset " + reminderBeforeExpiry);
		today.setTime(today.getTime() +  (reminderBeforeExpiry * 24 * 60 * 60 * 1000));
	 };

  // console.log("today", today);
  // console.log("expiryOn", expiryOn);
  // console.log("compare_dates(today, expiryOn)", compare_dates(today, expiryOn));

	return compare_dates(expiryOn, today);
};
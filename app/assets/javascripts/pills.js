$(document).ready(function() {

  $('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {

      var href = $(this).attr('href');    
      
      //set all nav tabs to inactive
      $('.nav-pills li').removeClass('active');
      
      // //get all nav tabs matching the href and set to active
      $('.nav-pills li a[href="'+href+'"]').closest('li').addClass('active');

      // //active tab
      $('.tab-pane').removeClass('active');
      $('.tab-pane'+href).addClass('active');
  })

});

// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()

import "../channels"

import "@primer/css/index.scss";
import "../../assets/stylesheets/application.scss"

import $ from 'jquery';
import moment from 'moment';
import 'daterangepicker/daterangepicker.js';
import 'daterangepicker/daterangepicker.css';

var AU = require('ansi_up');
var ansi_up = new AU.default;
ansi_up.escape_for_html = false;
ansi_up.use_classes = true;
window.ansi_up = ansi_up;

function getCookie(cname) {
  var name = cname + "=";
  var decodedCookie = decodeURIComponent(document.cookie);
  var ca = decodedCookie.split(';');
  for(var i = 0; i <ca.length; i++) {
    var c = ca[i];
    while (c.charAt(0) == ' ') {
      c = c.substring(1);
    }
    if (c.indexOf(name) == 0) {
      return c.substring(name.length, c.length);
    }
  }
  return "";
}

window.autoLoadLogs = getCookie("autoLoadLogs") === "true";

document.addEventListener("turbolinks:load", function() {
  // Dark Mode
  if (getCookie('timberDarkMode') === 'true') {
    $('body').addClass('dark')
    document.getElementById('darkSwitch').checked = true
  } else {
    $('body').removeClass('dark')
    document.getElementById('darkSwitch').checked = false
  }

  $('#darkSwitch').on('click', function(){
    $('body').toggleClass('dark')

    const darkMode = $('body').hasClass('dark')
    document.cookie = `timberDarkMode=${darkMode}`
    document.getElementById('darkSwitch').checked = darkMode
  })

  // Auto Load Logs
  if (getCookie('autoLoadLogs') === 'true') {
    document.getElementById('autoLoadLogs').checked = true
  } else {
    document.getElementById('autoLoadLogs').checked = false
  }

  $('#autoLoadLogs').on('click', function(){
    window.autoLoadLogs = !window.autoLoadLogs;
    document.cookie = `autoLoadLogs=${window.autoLoadLogs}`
  })

  // ANSI Escaping

  const ansis = document.getElementsByClassName('ansi-up');
  for(const ansiElement of ansis) {
    ansiElement.innerHTML = ansi_up.ansi_to_html(ansiElement.innerHTML);
  }

  // Date Picker
  const dateFormat = 'YYYY-MM-DDTHH:mm:ssZ'
  $('.js-date-range-picker').each(function(){
    const picker = $(this)
    picker.daterangepicker({
      timePicker: true,
      timePickerSeconds: true,
      autoUpdateInput: false,
      locale: { format: dateFormat, cancelLabel: 'Clear' },
      ranges: {
        'Last 5 minutes': [moment().subtract(5, 'minutes'), moment()],
        'Last 15 minutes': [moment().subtract(15, 'minutes'), moment()],
        'Last 60 minutes': [moment().subtract(60, 'minutes'), moment()],
        'Last 4 hours': [moment().subtract(4, 'hours'), moment()],
        'Today': [moment(), moment()],
        'Yesterday': [moment().subtract(1, 'days'), moment().subtract(1, 'days')],
        'Last 7 Days': [moment().subtract(6, 'days'), moment()],
        'Last 30 Days': [moment().subtract(29, 'days'), moment()],
      }
    })

    picker.on('apply.daterangepicker', function(ev, picker) {
      const val = picker.startDate.format(dateFormat) + ' - ' + picker.endDate.format(dateFormat)
      $(this).val(val);
    });

    picker.on('cancel.daterangepicker', function(ev, picker) {
      $(this).val('');
    });

    const startDate = picker.data('startdate')
    if (startDate && startDate !== '') picker.startDate = startDate

    const endDate = picker.data('enddate')
    if (endDate && endDate !== '') picker.endDate = endDate
  })
})

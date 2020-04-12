import consumer from "./consumer"

consumer.subscriptions.create("LogChannel", {
  received(data) {
    if (!this.applies(data)) return
    if (!window.autoLoadLogs) return

    const searchResults = document.getElementById('search-results')
    const searchList = searchResults.querySelectorAll('ul')[0]

    // Converts to real HTML Nodes
    var div = document.createElement('div');
    div.innerHTML = window.ansi_up.ansi_to_html(data.partial.trim());

    searchList.prepend(div.firstChild)
  },

  applies(data) {
    const urlParams = new URLSearchParams(window.location.search);
    const app = urlParams.get("application")
    if (app && app !== '' && app !== data.log.application) {
      return false
    }

    const source = urlParams.get("source")
    if (source && source !== '' && source !== data.log.source) {
      return false
    }

    function fuzzy_match(str, pattern){
      pattern = pattern.split("").reduce(function(a,b){ return a+".*"+b; });
      return (new RegExp(pattern)).test(str);
    }

    // TODO... how?
    // const query = urlParams.get("log")
    // if (query && query !== '' && !fuzzy_match(data.log.log, query)) {
    //   return false
    // }

    const timestamp = urlParams.get("time_range")
    if (timestamp) {
      const split = timestamp.split(' - ')

      // If the end time is before the log's timestamp... return false
      if (Date.parse(split[1]) < Date.parse(data.log.timestamp)) {
        return false
      }

      // If the start time is after the log's timestamp... return false
      if (Date.parse(split[0]) > Date.parse(data.log.timestamp)) {
        return false
      }
    }

    return true;
  }
});

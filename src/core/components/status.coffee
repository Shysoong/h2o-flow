{ lift, link, signal } = require("../modules/dataflow")
{ defer } = require('lodash')

exports.init = (_) ->
  defaultMessage = '就绪'
  _message = signal defaultMessage
  _connections = signal 0
  _isBusy = lift _connections, (connections) -> connections > 0
  
  onStatus = (category, type, data) ->
    console.debug '状态:', category, type, data
    switch category
      when 'server'
        switch type
          when 'request'
            _connections _connections() + 1
            defer _message, '正在请求 ' + data
          when 'response', 'error'
            _connections connections = _connections() - 1
            if connections
              defer _message, "正等待 #{connections} 个响应..."
            else
              defer _message, defaultMessage              
  
  link _.ready, ->
    link _.status, onStatus

  message: _message
  connections: _connections
  isBusy: _isBusy

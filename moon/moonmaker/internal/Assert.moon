
Assert = (condition, message) ->
  if not condition
    if message
      error("Assert hit! " .. message)
    else
      error("Assert hit!")

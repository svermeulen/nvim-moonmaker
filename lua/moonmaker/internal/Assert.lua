local Assert
Assert = function(condition, message)
  if not condition then
    if message then
      return error("Assert hit! " .. message)
    else
      return error("Assert hit!")
    end
  end
end

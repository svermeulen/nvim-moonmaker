
class Util
  tableContains: (table, element) ->
    for value in *table
      if value == element then
        return true

    return false

-- Get the sign of a number
function sign(x)
  return x > 0 and 1 or x < 0 and -1 or 0
end

-- Round val to the decimal number of places
function round(val, decimal)
  if (decimal) then
    return math.floor( (val * 10^decimal) + 0.5) / (10^decimal)
  else
    return math.floor(val+0.5)
  end
end

-- Get distance between two points
function distance(x1, y1, x2, y2)
  return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

-- Get angle (in radians) between two points
function angleBetween(x1, y1, x2, y2)
  return math.atan2(y2 - y1, x2 - x1)
end
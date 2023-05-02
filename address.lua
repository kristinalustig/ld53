A = {}

local addresses
local streets
local firstNames
local lastNames

function A.load()
  
  --name, neighborhood, numHouses
  streets = {
    {"Marigold Dr", 1, 12},
    {"Green Hill Rd", 1, 4},
    {"Bushy Tail Ln", 1, 4}, 
    {"Argent St", 1, 18},
    {"Corbera Rd", 2, 17},
    {"Valley St", 2, 3},
    {"Salmon Dr", 2, 4},
    {"Dunbar Ave", 2, 18},
    {"Slope Terr", 3, 6},
    {"Laurel Rd", 3, 17},
    {"Poplar Ln", 3, 4},
    {"East Ave", 3, 10}
  }
  
  GetFirstNames()
  GetLastNames()
  
  addresses = {}
  
  for k, v in ipairs(streets) do
    for i=1, v[3] do
      table.insert(addresses, {
          GetResidents(love.math.random(3)),
          i .. " " .. v[1],
          v[2]
        })
    end
  end
  
end


function A.getAddress(n)
  
  return addresses[n]
  
end

function GetResidents(num)
  
  local tempTable = {}
  local randL = love.math.random(#lastNames)
  
  for i=1, num do
    local randF = love.math.random(#firstNames)
    table.insert(tempTable, firstNames[randF] .. " " .. lastNames[randL])
  end
  
  return tempTable
  
end

function GetFirstNames()
  
  firstNames = {
    "Kristina",
    "Christina",
    "Matthew",
    "Fletcher",
    "Cody",
    "Dana",
    "Stephanie",
    "Casey",
    "Helene",
    "Sarah",
    "Karin",
    "Robert",
    "Terry",
    "Angelique",
    "Balthazar",
    "Penelope",
    "Henry",
    "Juan",
    "Frederich",
    "Maxwell",
    "Willow",
    "Andy",
    "Walter",
    "Benjamin",
    "Jill",
    "Anton",
    "Ekaterina",
    "Callie",
    "Alexis",
    "Nastasia",
    "Peter",
    "George",
    "Jonah",
    "Amy",
    "Dan",
    "Selina",
    "Michael",
    "Gary",
    "Rupert",
    "Xander",
    "Taissa",
    "Vanessa",
    "Natalie",
    "Misty",
    "Shauna",
    "Jackie",
    "Arthur",
    "Jeffrey",
    "Hank",
    "Dale",
    "Doug",
    "Geoff",
    "Veronica",
    "Keith",
    "Logan",
    "Lily",
    "Eli",
    "Felix",
    "Meg",
    "Wallace",
    "Robert",
    "Alicia",
    "David",
    "Jeremy",
    "Mark",
    "Suze",
    "Sophie",
    "Alan",
    "Diane",
    "Todd",
    "Beatrice",
    "Pierce",
    "Troy",
    "Abed",
    "Britta",
    "Annie",
    "Shirley",
    "Wayne",
    "Riley",
    "Katie",
    "Dan",
    "Darryl",
    "Raymond",
    "Jake",
    "Charles",
    "Rosa",
    "Gina",
    "Kevin",
    "Lindsey",
    "Tobias",
    "Lucille",
    "Buster",
    "Eleanor",
    "Tahani",
    "Jason",
    "Chidi",
    "Mindy",
    "Trina",
    "Amber",
    "Richard"
  }
  
end

function GetLastNames()
  
  lastNames = {
    "Hitchcock",
    "Scully",
    "Mulder",
    "Richardson",
    "Hart",
    "Giles",
    "Summers",
    "Rosenberg",
    "Harris",
    "Bluth",
    "Shellstrop",
    "Mars",
    "Meyers",
    "Lopez",
    "Diaz",
    "Echolls",
    "Casablancas",
    "Kane",
    "Santiago",
    "Holt",
    "Peralta",
    "Linetti",
    "Nichols",
    "Wain",
    "Marino",
    "Scott",
    "Winger",
    "Clark",
    "Perry",
    "Bergson",
    "Hawthorne",
    "Barnes",
    "Nguyen",
    "Chang",
    "Knope",
    "Swanson",
    "Smith",
    "Jones",
    "Lee",
    "Bardot",
    "Jefferson",
    "Garber",
    "Bach",
    "Young",
    "Campbell",
    "Baker",
    "Butcher",
    "Carver",
    "Merchant",
    "Jackson",
    "Douglas",
    "Anagonye",
    "Waterson",
    "Spears",
    "Wyatt",
    "Donald",
    "Klein",
    "Turner",
    "Williams",
    "Warner"
  }
  
end

return A
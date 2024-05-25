Config = {}

-- Default language for translations ("en" for English, "de" for German, "es" for Spanish, "fr" for French, "pl" for Polish, "ru" for Russian)
Config.defaultlang = "en"

-- Minimum and maximum time (in milliseconds) taken to search a crustacean hole
Config.SearchTimeMin = 5000 -- Minimum time in milliseconds
Config.SearchTimeMax = 20000 -- Maximum time in milliseconds

-- Time (in seconds) before a crustacean hole can be searched again
Config.SearchDelay = 7200 -- 2 hours

-- Default item count per search; Can be set as a fixed number or a table {min, max} for random rewards
Config.SearchRewardCount = {1, 3}

-- Chance to find nothing (e.g., 0.2 means 20% chance)
Config.NothingFoundChance = 0.5

-- List of items that can be found with their respective chances
Config.Items = {
    {name = "crawfish", chance = 0.5}, -- 40% chance to find a crawfish
    {name = "crab_c", chance = 0.1},     -- 30% chance to find a crab
}

-- Custom function to handle item usage (set to true if custom function is used)
Config.CrawfishCustomUseFunction = false

-- Name of the item given when harvesting
Config.CrawfishGivenItemName = "meat_crustacean"

-- Amount of items given when harvesting; Can be set as a fixed number or a table {min, max} for random rewards
Config.CrawfishGivenItemAmount = {1, 3}

-- Minimum and maximum times a hole can be searched before it becomes empty
Config.HoleUsageLimits = {1, 3}

-- List of coordinates for crustacean holes (vector3(x, y, z))
Config.CrawfishHoles = {
    vector3(2021.29150390625, -1789.32958984375, 40.51888656616211),
    vector3(2027.25390625, -1722.359619140625, 40.6132583618164),
    vector3(2042.18701171875, -1885.94384765625, 40.39377975463867),
    vector3(2045.3292236328125, -1785.771240234375, 40.67805480957031),
    vector3(2058.18505859375, -1866.734619140625, 40.50119018554687),
    vector3(2087.13134765625, -1859.825439453125, 40.5162353515625),
    vector3(2176.2734375, -693.794677734375, 40.6646499633789),
    vector3(2216.02978515625, -679.2449951171875, 40.62735748291015),
    vector3(2253.82666015625, -549.8944091796875, 40.5958137512207),
    vector3(2258.76611328125, -720.3011474609375, 40.47812271118164),
    vector3(2301.9091796875, -515.6649169921875, 40.82343673706055),
    vector3(2339.40478515625, -544.3302001953125, 40.8292007446289),
    vector3(2281.26, -640.65, 40.89)
}
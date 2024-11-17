Config = {}

Config.CheckDistance = 3.0
Config.Command = "checkvehicle"
Config.SearchTime = 5000
Config.RequiredJob = "police"
Config.RandomNames = {
    firstNames = {
        'John', 'Michael', 'David', 'James', 'Robert', 'William', 'Sarah', 
        'Emma', 'Emily', 'Maria', 'Thomas', 'Charles', 'Patricia', 'Jennifer'
    },
    lastNames = {
        'Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller',
        'Davis', 'Rodriguez', 'Martinez', 'Anderson', 'Taylor', 'Thomas', 'Moore'
    }
}

Config.Notifications = {
    noVehicle = "No vehicle nearby!",
    notCop = "You must be a police officer!",
    searching = "Checking vehicle information...",
    completed = "Vehicle check completed!",
    tooFar = "You're too far from the vehicle!"
}
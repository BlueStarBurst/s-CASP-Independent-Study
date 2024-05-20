import perception
import json
import re
import os

history = "" #!TODO: Implement memmory for the agent of maybe previous action taken
GUID_SPECIFIC_TAG = ["Hostile", "Fueled", "Harvestable"]

def classify_fraction(fraction, classification=["low", "half", "high"]):
    num_categories = len(classification)
    segment_size = 1 / num_categories
    # Calculate the index by finding which segment the fraction falls into
    index = int(fraction / segment_size)
    
    # Handle the edge case where the fraction is exactly 1
    if index == num_categories:
        index -= 1
    
    return classification[index]

def convert_json_to_predicate(json_string_data: str):
    predicates = []
    json_data = json.loads(json_string_data)
    # Load the entitiesOnScreen data to predicate
    for entity in json_data["entitiesOnScreen"]:
        predicates.append(f"item_on_screen({entity['Prefab']}, {entity['GUID']})")
        for k,v in entity.items():
            if k == "Prefab" or k == "GUID":
                continue
            elif k == "Quantity":
                predicates.append(f"quantity({entity['GUID']}, {v})")
            elif k in GUID_SPECIFIC_TAG:
                predicates.append(f"{str.lower(k)}({entity['GUID']})") 
            elif v == True:
                predicate_str = f"{str.lower(k)}({entity['Prefab']})"
                if predicate_str not in predicates:
                    predicates.append(predicate_str)
    
    
    # Load the inventory data to predicate
    inventory = {}
    for entity in json_data["inventory"]:
        inventory[entity["Prefab"]] = inventory.get(entity["Prefab"], 0) + entity["Quantity"]
        predicates.append(f"slot_in_inventory({entity['Prefab']}, {entity['GUID']})")
        for k,v in entity.items():
            if k == "Prefab" or k == "GUID":
                continue
            elif type(v) == bool and v == True: #Known attributes to all same entities
                predicate_str = f"{str.lower(k)}({entity['Prefab']})"
                if predicate_str not in predicates:
                    predicates.append(predicate_str)
    for k,v in inventory.items():
        predicates.append(f"item_in_inventory({k}, {v})")
        
    #Load the equipped data
    for entity in json_data["equipped"]:
        predicates.append(f"equipment({entity['Prefab']})") 
        predicates.append(f"equipment_guid({entity['Prefab']}, {entity['GUID']})")
        for k,v in entity.items():
            if k == "Prefab" or k == "GUID":
                continue
            elif k == "Quantity":
                predicates.append(f"quantity({entity['GUID']}, {v})")
            elif k in GUID_SPECIFIC_TAG:
                predicates.append(f"{str.lower(k)}({entity['GUID']})") 
            elif v == True:
                predicate_str = f"{str.lower(k)}({entity['Prefab']})"
                if predicate_str not in predicates:
                    predicates.append(predicate_str)
    
    
    
    #Sanity, Health, Hunger
    def get_status(data):
        numbers = re.findall(r'\d+\.\d+', data)
        current = int(float(numbers[0]))
        max = int(float(numbers[1]))
        return classify_fraction(current/max)
    
    #Sanity
    predicates.append(f"sanity({get_status(json_data['sanity'])})")
    
    #Hunger
    predicates.append(f"hunger({get_status(json_data['hunger'])})")
    
    #Health
    predicates.append(f"health({get_status(json_data['health'])})")
    
    
    timeOfDay = json_data["timeOfDay"]
    currentHour = timeOfDay["currentHour"]
    timePeriods = timeOfDay["timePeriods"]
    
    currentPhase = "day"
    if float(currentHour) >= float(timePeriods["day"]) + float(timePeriods["dusk"]):
        currentPhase = "night"
        percentagePhase = (float(currentHour) - float(timePeriods["day"]) - float(timePeriods["dusk"])) / (float(timePeriods["night"]))
    elif float(currentHour) >= float(timePeriods["day"]):
        currentPhase = "dusk"
        percentagePhase = (float(currentHour) - float(timePeriods["day"])) / (float(timePeriods["dusk"]))        
    else:
        percentagePhase = (float(currentHour) / float(timePeriods["day"]))
    
    #Time
    # currentPhase = json_data["time"]["currentPhase"]
    # percentagePhase = json_data["time"]["percentagePhase"]
    predicates.append(f"time({currentPhase}, {classify_fraction(percentagePhase, ['early', 'mid', 'end'])})")
    
    predicates_str = ""
    for predicate in predicates:
        if predicate[-1] == ".":
            predicates_str += predicate + "\n"
        else:
            predicates_str += predicate + ".\n"
            
    return predicates_str


with open("test_data.json", "r") as f:
    data = f.read()
    predicate = convert_json_to_predicate(data)

    #Save the predicates to a file
    with open("predicates.pl", "w") as f:
        f.write(predicate)
        
    # read all lines the predicates from actions.pl
    with open("agents/v0_HelloWorld_Wilson/action.pl", "r") as f:
        actions = f.read()
        # combine the predicates and actions
        with open("combined.pl", "w") as f:
            f.write(predicate + "\n" + actions)
            f.write("\n")
            f.write("?- scasp(action(DESC, FUNC, ARGS)).")
            
            # run the combined.pl file and get the output using os.system
            os.system("swipl -s combined.pl")
    
        
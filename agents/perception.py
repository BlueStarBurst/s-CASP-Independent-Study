import json
import re
import os
from subprocess import run


last_desc, last_func, last_args = "none", "none", "none"

EQIVALENT_ENTITY_DICT = {
    "berrybush": "berries",
    "sapling": "twigs",
    "grass": "cutgrass",
    "carrot_planted": "carrot",
}

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
        entity_name = entity["Prefab"]
        entity_name = EQIVALENT_ENTITY_DICT.get(entity_name, entity_name)
                
        predicates.append(f"item_on_screen({entity_name}, {entity['GUID']})")
        for k,v in entity.items():
            if k == "Prefab" or k == "GUID":
                continue
            elif k == "Quantity":
                predicates.append(f"quantity({entity['GUID']}, {v})")
            elif v == True:
                predicates.append(f"{str.lower(k)}({entity['GUID']})") 
    
    
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
    
    #Time
    currentPhase = json_data["time"]["currentPhase"]
    percentagePhase = json_data["time"]["percentagePhasePassed"]
    predicates.append(f"time({currentPhase}, {classify_fraction(percentagePhase, ['early', 'mid', 'end'])})")
    
    predicates_str = ""
    for predicate in predicates:
        if predicate[-1] == ".":
            predicates_str += predicate + "\n"
        else:
            predicates_str += predicate + ".\n"
            
    return predicates_str


def get_action(json_string_data: str):
    
    predicate = convert_json_to_predicate(json_string_data)
    
    #Save the predicates to a file
    with open("predicates.pl", "w") as f:
        f.write(predicate)
        f.close()
    
    # read all lines the predicates from actions.pl
    with open("agents/v0_HelloWorld_Wilson/action.pl", "r") as f:
        actions = f.read()
        f.close()
    # combine the predicates and actions
    with open("combined.pl", "w") as f:
        f.write(predicate + "\n" + actions)
        f.write("\n")
        f.write(f"?- action({last_desc}, {last_func}, {last_args}).")
        f.close()
    # run the combined.pl file and get the output using os.system
    output = run(["scasp", "combined.pl", '-n1'], capture_output=True)    
    #Check if there is "no models"
    print("no models" in output.stdout.decode("utf-8"))
    if "no models" in output.stdout.decode("utf-8"):
        
        with open("combined.pl", "w") as f:
            #Remove the last line
            f.write(predicate + "\n" + actions)
            f.write("\n")
            f.write(f"?- action(DESC, FUNC, ARGS).")
            # f.write(f"?- good_pick(GUID).")
            f.close()
        
        output = run(["scasp", "combined.pl", '-n100'], capture_output=True)
        
        desc = ""
        func = ""
        args = ""
        
        print("output:", output.stdout.decode("utf-8"))
        print("error:", output.stderr.decode("utf-8"))
        
        # get line with DESC =
        output = output.stdout.decode("utf-8").split("\n")
        for line in output:
            if "DESC =" in line:
                desc = line.split("DESC = ")[1]
            elif "FUNC =" in line:
                func = line.split("FUNC = ")[1]
            elif "ARGS =" in line:
                args = line.split("ARGS = ")[1]
                
        print("DESC:", desc)
        print("FUNC:", func)
        print("ARGS:", args)
        return desc, func, args
    else:
        return last_desc, last_func, last_args
        
        
        
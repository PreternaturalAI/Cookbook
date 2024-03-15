//
//  Prompts.swift
//  HealthApp
//
//  Created by Jared Davidson on 3/14/24.
//

import Foundation

struct Prompts {
    static var isThisAMealPrompt: String {
        return "Only return the result: Is this food? Answer w/: true or false"
    }
    
    static var mealNamePrompt: String {
        return "Only return the result: What's this food called?"
    }
    
    static var mealComponentsPrompt: String {
        return "Only return the result: What is it made out of?"
    }
    
    static var mealDescriptionPrompt: String {
        return "Only return the result: Give me a very short description about the food."
    }
    
    static var mealProsPrompt: String {
        return "Only return the result: Give me a very short list on the pros of the food."
    }
    
    static var mealConsPrompt: String {
        return "Only return the result: Give me a very short list on the cons of the food."
    }
    
    static var mealTagsPrompt: String {
        return "Only return the result: Give me a very short list on some tags you might give to the food. (High carb, low calory, etc...)"
    }
}

public with sharing class Exercise1 {

    // Make the method static for direct access
    public static Map<String, Integer> exercise1(List<String> namesList) {
        Map<String, Integer> nameToOccurrencesMap = new Map<String, Integer>();

        for (String name : namesList) {
            if (nameToOccurrencesMap.containsKey(name)) {
                nameToOccurrencesMap.put(name, nameToOccurrencesMap.get(name) + 1);
            } else {
                nameToOccurrencesMap.put(name, 1);
            }
        }

        return nameToOccurrencesMap;
    }

    // Sample test method to run
    public static void testExercise1() {
        List<String> namesList = new List<String>{
            'maria', 'maria', 'john', 'john', 'john', 'john', 'john', 
            'john', 'john', 'john', 'john', 'mario', 'darine', 'fawzy'
        };

        Map<String, Integer> result = exercise1(namesList);

        System.debug(result);  // Output: {maria=2, john=9, mario=1, darine=1, fawzy=1}
    }
}

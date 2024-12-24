public class GeneratorPin {
    public static String generateUniquePin() {
        String pin;
        Boolean isUnique = false;
        
        while (!isUnique) {
            pin = generatePin();
            Integer count = [SELECT COUNT() FROM Cell__c WHERE Pin__c = :pin LIMIT 1];
            if (count == 0) {
                isUnique = true;
            }
        }
        return pin;
    }
    
    private static String generatePin() {
        String chars = '0123456789';
        String pin = '';
        for (Integer i = 0; i < 6; i++) {
            Integer randIndex = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            pin += chars.substring(randIndex, randIndex + 1);
        } 
        return pin;
    }
}
@isTest
public class ProductGeneratorTest {
    @isTest
    static void testCreateProducts() {
        // Start the test
        Test.startTest();

        // Call the method to test
        ProductGenerator.createProducts();

        // End the test
        Test.stopTest();

        // Query the created products
        List<Product2> products = [SELECT Name, ProductCode, Description, Height__c, Length__c, Width__c, IsActive, Family
        FROM Product2];

        // Assertions
        System.assertEquals(100, products.size(), '100 products should be created.');

        Set<String> uniqueCodes = new Set<String>();
        for (Product2 prod : products) {
            // Verify Name
            System.assert(prod.Name.startsWith('Dnipro-M') || prod.Name.startsWith('RZTK') ||
                    prod.Name.startsWith('Bluetty') || prod.Name.startsWith('EcoFlow'),
                    'Product Name should start with a valid brand.');

            // Verify ProductCode uniqueness
            System.assert(!uniqueCodes.contains(prod.ProductCode), 'ProductCode should be unique.');
            uniqueCodes.add(prod.ProductCode);

            // Verify Description
            System.assert(prod.Description.contains('inverter is designed for optimal parcel delivery compatibility'),
                    'Description should match the expected format.');

            // Verify dimensions and ranges based on sizes
            if (prod.Height__c >= 50) {
                System.assert(prod.Height__c >= 50 && prod.Height__c < 60, 'Height for Large should be 50-59.');
                System.assert(prod.Length__c >= 40 && prod.Length__c < 50, 'Length for Large should be 40-49.');
                System.assert(prod.Width__c >= 30 && prod.Width__c < 40, 'Width for Large should be 30-39.');
            } else if (prod.Height__c >= 30) {
                System.assert(prod.Height__c >= 30 && prod.Height__c < 40, 'Height for Medium should be 30-39.');
                System.assert(prod.Length__c >= 20 && prod.Length__c < 30, 'Length for Medium should be 20-29.');
                System.assert(prod.Width__c >= 15 && prod.Width__c < 20, 'Width for Medium should be 15-19.');
            } else {
                System.assert(prod.Height__c >= 15 && prod.Height__c < 20, 'Height for Small should be 15-19.');
                System.assert(prod.Length__c >= 10 && prod.Length__c < 15, 'Length for Small should be 10-14.');
                System.assert(prod.Width__c >= 5 && prod.Width__c < 10, 'Width for Small should be 5-9.');
            }

            // Verify IsActive
            System.assertEquals(true, prod.IsActive, 'Product should be active.');

            // Verify Family
            System.assertEquals('Inverters', prod.Family, 'Family should be Inverters.');
        }
    }
}
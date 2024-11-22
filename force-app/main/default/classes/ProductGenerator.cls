public class ProductGenerator {
    public static void createProducts() {
        List<Product2> products = new List<Product2>();
        Set<String> usedProductCodes = new Set<String>();

        String[] brands = new String[] { 'Dnipro-M', 'RZTK', 'Bluetty', 'EcoFlow' };
        String[] sizeCategories = new String[] { 'Large', 'Medium', 'Small' };

        for (Integer i = 0; i < 100; i++) {
            Product2 prod = new Product2();

            String brand = brands[(Integer)Math.floor(Math.random() * brands.size())];

            prod.Name = brand + ' Inverter Model ' + (i + 1);

            String size = sizeCategories[Math.mod(i, sizeCategories.size())];

            if (size == 'Large') {
                prod.Height__c = 50 + (Integer)Math.floor(Math.random() * 10); // Range 50-59
                prod.Length__c = 40 + (Integer)Math.floor(Math.random() * 10); // Range 40-49
                prod.Width__c = 30 + (Integer)Math.floor(Math.random() * 10);  // Range 30-39
            } else if (size == 'Medium') {
                prod.Height__c = 30 + (Integer)Math.floor(Math.random() * 10); // Range 30-39
                prod.Length__c = 20 + (Integer)Math.floor(Math.random() * 10); // Range 20-29
                prod.Width__c = 15 + (Integer)Math.floor(Math.random() * 5);   // Range 15-19
            } else if (size == 'Small') {
                prod.Height__c = 15 + (Integer)Math.floor(Math.random() * 5);  // Range 15-19
                prod.Length__c = 10 + (Integer)Math.floor(Math.random() * 5);  // Range 10-14
                prod.Width__c = 5 + (Integer)Math.floor(Math.random() * 5);    // Range 5-9
            }

            String productCode;

            do {
                productCode = generateProductCode(brand);
            } while (
                    usedProductCodes.contains(productCode)
            );

            prod.ProductCode = productCode;
            usedProductCodes.add(productCode);

            prod.Description = 'The ' + brand + ' inverter is designed for optimal parcel delivery compatibility.';

            prod.IsActive = true;

            prod.Family = 'Inverters';

            products.add(prod);
        }

        try {
            insert products;
            System.debug('Products created successfully: ' + products.size());
        } catch (DmlException e) {
            System.debug('Error while inserting products: ' + e.getMessage());
        }
    }

    private static String generateProductCode(String brand) {
        String prefix = brand.substring(0, 2).toUpperCase();
        String code = prefix;

        for (Integer i = 0; i < 4; i++) {
            code += String.valueOf((Integer)Math.floor(Math.random() * 10));
        }

        return code;
    }
}
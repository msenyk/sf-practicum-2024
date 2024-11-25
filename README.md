# sf-practicum-2024
Учбовий проєкт виробничої практики по Salesforce

[Опис задачі](https://docs.google.com/document/d/1Zj1pv4o84AQMehs_TjTEMYZ4R4DNCahExgIJDkcW5_Y/edit?usp=sharing)


Інструкції: 
 
  <b>1. Як задеплоїти код з репозиторію GitHub</b></br>
  
   Після того як зміни буди змерджені у гілку master, можна зедеплоїти їх за допомогою GitHub Actions (YAML Pipeline)
     
     - відкрийте вкладку Actions
     - виберіть "Salesforce CRM Deploy"
     - клікніть "Run workflow" і оберіть гілку з якої буде виконано деплой
     
     Виберіть виконуваний workflow і слідкуйте за логами для відстеження прогресу.
     Після успішного завершення метадані будуть задеплоєні у ваш навчальний Salesforce Org.

  <b>2. Як створити тестові дані</b></br>
   На прикладі приведеного шматка тестового класу

   
   <code>
     @isTest
     private class TestDataCreatorTest {
         public static void createTestData() {
             // Create an Account
             Account testAccount = new Account(
                     Name = 'Test Account',
                     Phone = '123-456-7890',
                     BillingStreet = '123 Test St',
                     BillingCity = 'Test City',
                     BillingState = 'Test State',
                     BillingPostalCode = '12345',
                     BillingCountry = 'USA'
             );
             insert testAccount
             // Create a Contact
             Contact testContact = new Contact(
                     FirstName = 'John',
                     LastName = 'Doe',
                     Phone = '987-654-3210',
                     Email = 'johndoe@example.com',
                     AccountId = testAccount.Id
             );
             insert testContact;   
             // Create a Product2
             Product2 testProduct = new Product2(
                     Name = 'Test Product',
                     IsActive = true, // Required for use in PriceBookEntry
                     Description = 'A sample product for testing'
             );
             insert testProduct;
             // Create a PriceBookEntry (Required for associating Product2 with Opportunities or Quotes)
             Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
             PricebookEntry testPricebookEntry = new PricebookEntry(
                     Pricebook2Id = standardPricebook.Id,
                     Product2Id = testProduct.Id,
                     UnitPrice = 100.00,
                     IsActive = true
             );
             insert testPricebookEntry;
             // Create an Opportunity
             Opportunity testOpportunity = new Opportunity(
                     Name = 'Test Opportunity',
                     StageName = 'Prospecting', // Required field
                     CloseDate = Date.today().addDays(30), // Required field
                     AccountId = testAccount.Id
             );
             insert testOpportunity;
             // Create a Quote
             Quote testQuote = new Quote(
                     Name = 'Test Quote',
                     OpportunityId = testOpportunity.Id,
                     AccountId = testAccount.Id,
                     Pricebook2Id = standardPricebook.Id,
                     ExpirationDate = Date.today().addDays(60) // Optional but commonly included
             );
             insert testQuote;
             System.debug('Test data created successfully');
         }
         @isTest
         static void testCreateTestData() {
             Test.startTest();
             createTestData();
             Test.stopTest();
             // Assertions
             System.assertEquals(1, [SELECT COUNT() FROM Account]);
             System.assertEquals(1, [SELECT COUNT() FROM Contact]);
             System.assertEquals(1, [SELECT COUNT() FROM Product2]);
             System.assertEquals(1, [SELECT COUNT() FROM Opportunity]);
             System.assertEquals(1, [SELECT COUNT() FROM Quote]);
         }
     }
   </code>

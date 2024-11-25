# sf-practicum-2024
Учбовий проєкт виробничої практики по Salesforce

[Опис задачі](https://docs.google.com/document/d/1Zj1pv4o84AQMehs_TjTEMYZ4R4DNCahExgIJDkcW5_Y/edit?usp=sharing)


Інструкції: 
 
  <h2>1. Як задеплоїти код з репозиторію GitHub</h2></br>
  
   Після того як зміни буди змерджені у гілку master, можна зедеплоїти їх за допомогою GitHub Actions (YAML Pipeline)
     
     - відкрийте вкладку Actions
     - виберіть "Salesforce CRM Deploy"
     - клікніть "Run workflow" і оберіть гілку з якої буде виконано деплой
     
     Виберіть виконуваний workflow і слідкуйте за логами для відстеження прогресу.
     Після успішного завершення метадані будуть задеплоєні у ваш навчальний Salesforce Org.

  <h2>2. Як створити тестові дані</h2></br>
  
   На прикладі приведеного шматка тестового класу

   <style>
    code {
      font-family: Consolas,"courier new";
      color: crimson;
      background-color: #f1f1f1;
      padding: 2px;
      font-size: 105%;
    }
  </style>
  
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

   <h2>3. Як створити або редагувати Page Layout</h2>
   
    Перейдіть до Object Manager:
    
    Відкрийте Setup у Salesforce.
    У Quick Find Box введіть Object Manager і оберіть його.
    Виберіть об'єкт, для якого ви хочете створити або редагувати Page Layout.
    Перейдіть до розділу Page Layouts:
    
    У Object Manager виберіть вкладку Page Layouts у меню зліва.
    Натисніть New для створення нового Page Layout або виберіть існуючий для редагування.
    Додайте поля та секції:
    
    У редакторі Page Layout ви можете перетягувати потрібні елементи:
    Поля: Додайте необхідні поля до відповідних секцій.
    Секції: Натисніть Add Section, щоб створити нову секцію, і дайте їй назву.
    Упорядкуйте поля за логікою використання.
    Налаштуйте Related Lists:
    
    У нижній частині редактора ви знайдете Related Lists.
    Перетягніть потрібні списки у макет і налаштуйте видимі поля для кожного списку, натиснувши wrench icon.
    Встановіть Field Properties:
    
    Натисніть на будь-яке поле, щоб відкрити його властивості.
    Ви можете налаштувати:
    Read-Only: Тільки для перегляду.
    Required: Обов'язкове поле.
    Налаштуйте користувацький макет для різних профілів:
    
    У вкладці Page Layout Assignment визначте, які профілі користувачів бачитимуть відповідний макет.
    Збережіть зміни:
    
    Натисніть Save, щоб зберегти новий або відредагований Page Layout.
    Приклад створення макету для об'єкта Account
    Додайте секцію Account Details з основними полями, такими як:
    Account Name
    Industry
    Annual Revenue
    Додайте секцію Contact Information:
    Phone
    Email
    Website
    У секції Related Lists додайте:
    Opportunities
    Cases
    Contacts

<h2>Як створити Lightning сторінку</h2>
    
    У Salesforce перейдіть до Setup.
    У Quick Find Box введіть Lightning App Builder і оберіть його.
    Натисніть кнопку New:
    
    У Lightning App Builder натисніть New для створення нової сторінки.
    
    Оберіть тип сторінки:
    
      Вам буде запропоновано вибрати тип сторінки:
      App Page: Сторінка для додатка.
      Record Page: Сторінка для певного запису об'єкта.
      Home Page: Домашня сторінка.
      Для прикладу виберіть Record Page і натисніть Next.
      
    Виберіть об'єкт:
    
      Виберіть об'єкт, для якого ви створюєте сторінку, наприклад, Account або Custom Object.
      Натисніть Next.
      
    Оберіть макет сторінки:
    
    Salesforce пропонує кілька готових макетів:
      Full-Width: Одна секція на всю ширину.
      Two Regions: Дві секції.
      Three Regions: Три секції з різними розмірами.
      Виберіть макет і натисніть Finish.
      
    Додайте компоненти на сторінку:
    
      У правій панелі виберіть доступні компоненти (наприклад, Highlights Panel, Record Details, Related Lists).
      Перетягніть потрібні компоненти на сторінку.
    
    Налаштуйте компоненти:
    
      Клацніть на компонент, щоб налаштувати його властивості (наприклад, видимість, фільтри, макет полів).
    
    Попередній перегляд сторінки:
    
      Використовуйте кнопку Preview, щоб перевірити, як виглядає сторінка.
      Збережіть і активуйте сторінку:
    
    Натисніть Save, щоб зберегти сторінку.
    
    Натисніть Activate, щоб зробити сторінку доступною:
    
      Встановіть сторінку як Org Default, App Default або Record Type Default.
      Приклад створення Lightning сторінки для об'єкта Cell__c
      Виберіть Record Page для об'єкта Cell__c.
      
    Додайте наступні компоненти:
    
      Highlights Panel (для відображення ключової інформації).
      Record Details (для перегляду полів запису).
      Related List - Single (наприклад, список пов'язаних Opportunities або Contacts).
      Збережіть сторінку та активуйте її як Org Default.
      Поради
      Використовуйте Dynamic Visibility, щоб показувати компоненти лише для певних профілів або умов.

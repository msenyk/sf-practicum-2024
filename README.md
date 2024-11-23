# sf-practicum-2024
Учбовий проєкт виробничої практики по Salesforce

[Опис задачі](https://docs.google.com/document/d/1Zj1pv4o84AQMehs_TjTEMYZ4R4DNCahExgIJDkcW5_Y/edit?usp=sharing)


Інструкції: Як задеплоїти код

1. Деплой за допомогою GitHub Actions (YAML Pipeline)
У вашому проєкті налаштовано GitHub Actions для автоматизації деплою, яке визначено у файлі .github/workflows/deploy.yml. Виконайте наступні кроки для розгортання:

Передумови
Salesforce CLI: Пайплайн використовує Salesforce CLI для виконання деплою.

Запуск пайплайна:

- відкрийте вкладку Actions
- виберіть "Salesforce CRM Deploy"
- клікніть "Run workflow" і оберіть гілку з якої буде виконано деплой

Виберіть виконуваний workflow і слідкуйте за логами для відстеження прогресу.
Після успішного завершення метадані будуть задеплоєні у вказаний Org Salesforce.


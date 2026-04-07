# 💰 Personal Finance Tracker

A full-stack personal finance management web application built with **Java 17**, **Kotlin**, and **Spring Boot 3**. Track your income, expenses, and spending habits across multiple accounts with a clean dark dashboard UI.

🔗 **Live Demo:** Run locally at `http://localhost:8080`

---

## 📸 Features

- 🏦 Create multiple accounts (Checking, Savings, Credit)
- 💸 Log income and expenses with category, description, and date
- 📊 Real-time balance updates on every transaction
- 🗂 Category-wise spending summary with visual progress bars
- 🗑 Delete transactions with automatic balance correction
- 🌙 Responsive dark UI — works on desktop and mobile

---

## 🛠 Tech Stack

| Layer | Technology |
|---|---|
| Backend Language | Java 17 + Kotlin 1.9.23 (mixed project) |
| Framework | Spring Boot 3.2.5 |
| Web Layer | Spring MVC (Kotlin Controller) |
| ORM / Persistence | Spring Data JPA + Hibernate 6 |
| Database | H2 In-Memory Database |
| UI / Templating | Thymeleaf 3 + Bootstrap 5.3 |
| Build Tool | Apache Maven |
| Server | Embedded Apache Tomcat |

---

## 🏗 Architecture

```
Browser (Thymeleaf UI — Bootstrap 5 Dark Dashboard)
                    │
         WebController.kt  ← Kotlin
                    │
    ┌───────────────┼───────────────┐
UserService.java  AccountService.java  TransactionService.java
                    │
         Spring Data JPA Repositories
                    │
           H2 In-Memory Database
         (users | account | transaction)
```

---

## 📁 Project Structure

```
finance-tracker/
├── src/main/java/com/financetracker/finance_tracker/
│   ├── FinanceTrackerApplication.java
│   ├── model/
│   │   ├── User.java
│   │   ├── Account.java
│   │   ├── Transaction.java
│   │   └── SpendingSummary.java
│   ├── repository/
│   │   ├── UserRepository.java
│   │   ├── AccountRepository.java
│   │   └── TransactionRepository.java
│   └── service/
│       ├── UserService.java
│       ├── AccountService.java
│       └── TransactionService.java
│
├── src/main/kotlin/com/financetracker/finance_tracker/
│   └── controller/
│       └── WebController.kt          ← Kotlin MVC Controller
│
├── src/main/resources/
│   ├── templates/
│   │   ├── setup.html                ← First-time setup page
│   │   ├── index.html                ← Dashboard
│   │   └── account.html             ← Account detail + transactions
│   └── application.properties
│
└── pom.xml
```

---

## 🗄 Database Schema

```sql
CREATE TABLE users (
    id    BIGINT PRIMARY KEY AUTO_INCREMENT,
    name  VARCHAR(255),
    email VARCHAR(255)
);

CREATE TABLE account (
    id      BIGINT PRIMARY KEY AUTO_INCREMENT,
    name    VARCHAR(255),
    type    ENUM('CHECKING', 'SAVINGS', 'CREDIT'),
    balance FLOAT,
    user_id BIGINT REFERENCES users(id)
);

CREATE TABLE transaction (
    id          BIGINT PRIMARY KEY AUTO_INCREMENT,
    amount      FLOAT,
    category    VARCHAR(255),
    description VARCHAR(255),
    type        ENUM('INCOME', 'EXPENSE'),
    date        DATE,
    account_id  BIGINT REFERENCES account(id)
);
```

---

## 🔗 API Routes

| Method | URL | Description |
|---|---|---|
| GET | `/` | Dashboard (or setup if new user) |
| POST | `/user/create` | Create new user |
| POST | `/account/create` | Create new account |
| GET | `/account/{id}` | Account detail + transactions |
| POST | `/transaction/add` | Add income or expense |
| POST | `/transaction/delete/{id}` | Delete a transaction |

---

## 🚀 How to Run

### Prerequisites
- Java 17
- Maven 3.x
- macOS / Linux / Windows

### Steps

```bash
# Clone the repo
git clone https://github.com/Ompatil04/PersonalFinanceTracker.git
cd PersonalFinanceTracker

# Set Java 17 (macOS with Homebrew)
export JAVA_HOME=/opt/homebrew/opt/openjdk@17
export PATH="$JAVA_HOME/bin:$PATH"

# Run
mvn spring-boot:run
```

Open your browser at **http://localhost:8080**

---

## 📌 Key Implementation Highlights

- **Mixed Java + Kotlin** — models, repositories, and services in Java; web controller in Kotlin, demonstrating cross-language Spring Boot interoperability
- **Kotlin-first Maven build** — configured `kotlin-maven-plugin` to compile Kotlin before Java so Kotlin classes are visible to the Java compiler
- **JPA Entity Relationships** — `User → Account → Transaction` with `@OneToMany` / `@ManyToOne` mappings and cascade operations
- **Stream API aggregation** — Java streams used for category-based expense grouping and `DoubleSummaryStatistics` for spending totals
- **Thymeleaf server-side rendering** — zero JavaScript frameworks; all logic handled server-side with clean HTML templates


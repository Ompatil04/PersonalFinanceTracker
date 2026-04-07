#!/bin/bash
set -e
echo "🚀 Adding Kotlin WebController + Thymeleaf UI..."

# ── Create Kotlin controller folder & templates folder ──
mkdir -p src/main/kotlin/com/financetracker/finance_tracker/controller
mkdir -p src/main/resources/templates
echo "✅ Folders ready"

# ── pom.xml — adds Kotlin + Thymeleaf to existing project ──
cat > pom.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>3.2.5</version>
    <relativePath/>
  </parent>
  <groupId>com.financetracker</groupId>
  <artifactId>finance-tracker</artifactId>
  <version>0.0.1-SNAPSHOT</version>
  <packaging>jar</packaging>

  <properties>
    <java.version>17</java.version>
    <kotlin.version>1.9.23</kotlin.version>
  </properties>

  <dependencies>
    <!-- Existing dependencies -->
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    <dependency>
      <groupId>com.h2database</groupId>
      <artifactId>h2</artifactId>
      <scope>runtime</scope>
    </dependency>

    <!-- NEW: Thymeleaf UI -->
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-thymeleaf</artifactId>
    </dependency>

    <!-- NEW: Kotlin -->
    <dependency>
      <groupId>org.jetbrains.kotlin</groupId>
      <artifactId>kotlin-stdlib</artifactId>
      <version>${kotlin.version}</version>
    </dependency>
    <dependency>
      <groupId>org.jetbrains.kotlin</groupId>
      <artifactId>kotlin-reflect</artifactId>
      <version>${kotlin.version}</version>
    </dependency>
    <dependency>
      <groupId>com.fasterxml.jackson.module</groupId>
      <artifactId>jackson-module-kotlin</artifactId>
    </dependency>
  </dependencies>

  <build>
    <plugins>
      <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
      </plugin>

      <!-- Kotlin compiles FIRST, then Java sees the Kotlin classes -->
      <plugin>
        <groupId>org.jetbrains.kotlin</groupId>
        <artifactId>kotlin-maven-plugin</artifactId>
        <version>${kotlin.version}</version>
        <executions>
          <execution>
            <id>compile</id>
            <phase>process-sources</phase>
            <goals><goal>compile</goal></goals>
            <configuration>
              <sourceDirs>
                <sourceDir>${project.basedir}/src/main/kotlin</sourceDir>
                <sourceDir>${project.basedir}/src/main/java</sourceDir>
              </sourceDirs>
            </configuration>
          </execution>
          <execution>
            <id>test-compile</id>
            <phase>test-compile</phase>
            <goals><goal>test-compile</goal></goals>
          </execution>
        </executions>
        <configuration>
          <compilerPlugins>
            <plugin>spring</plugin>
          </compilerPlugins>
        </configuration>
        <dependencies>
          <dependency>
            <groupId>org.jetbrains.kotlin</groupId>
            <artifactId>kotlin-maven-allopen</artifactId>
            <version>${kotlin.version}</version>
          </dependency>
        </dependencies>
      </plugin>

      <!-- Java compiles AFTER Kotlin -->
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-compiler-plugin</artifactId>
        <executions>
          <execution>
            <id>default-compile</id>
            <phase>none</phase>
          </execution>
          <execution>
            <id>default-testCompile</id>
            <phase>none</phase>
          </execution>
          <execution>
            <id>java-compile</id>
            <phase>compile</phase>
            <goals><goal>compile</goal></goals>
          </execution>
          <execution>
            <id>java-test-compile</id>
            <phase>test-compile</phase>
            <goals><goal>testCompile</goal></goals>
          </execution>
        </executions>
      </plugin>
    </plugins>
  </build>
</project>
EOF
echo "✅ pom.xml updated"

# ── WebController.kt — written in Kotlin ───────
cat > src/main/kotlin/com/financetracker/finance_tracker/controller/WebController.kt << 'EOF'
package com.financetracker.finance_tracker.controller

import com.financetracker.finance_tracker.model.Account
import com.financetracker.finance_tracker.model.Transaction
import com.financetracker.finance_tracker.repository.TransactionRepository
import com.financetracker.finance_tracker.service.AccountService
import com.financetracker.finance_tracker.service.TransactionService
import com.financetracker.finance_tracker.service.UserService
import org.springframework.stereotype.Controller
import org.springframework.ui.Model
import org.springframework.web.bind.annotation.*

@Controller
class WebController(
    private val userService: UserService,
    private val accountService: AccountService,
    private val transactionService: TransactionService,
    private val txRepo: TransactionRepository
) {

    @GetMapping("/")
    fun index(model: Model): String {
        val users = userService.findAll()
        if (users.isEmpty()) return "setup"
        val user = users[0]
        val accounts = accountService.findByUser(user.id)
        model.addAttribute("user", user)
        model.addAttribute("accounts", accounts)
        model.addAttribute("totalBalance", accounts.sumOf { it.balance })
        model.addAttribute("accountTypes", Account.AccountType.values())
        return "index"
    }

    @PostMapping("/user/create")
    fun createUser(@RequestParam name: String, @RequestParam email: String): String {
        userService.create(name, email)
        return "redirect:/"
    }

    @PostMapping("/account/create")
    fun createAccount(
        @RequestParam userId: Long,
        @RequestParam name: String,
        @RequestParam type: Account.AccountType
    ): String {
        accountService.create(userId, name, type)
        return "redirect:/"
    }

    @GetMapping("/account/{id}")
    fun accountDetail(@PathVariable id: Long, model: Model): String {
        val account = accountService.findById(id)
        val transactions = txRepo.findByAccountId(id).sortedByDescending { it.date }
        val totalIncome = transactions.filter { it.type == Transaction.TransactionType.INCOME }.sumOf { it.amount }
        val totalExpense = transactions.filter { it.type == Transaction.TransactionType.EXPENSE }.sumOf { it.amount }
        model.addAttribute("account", account)
        model.addAttribute("transactions", transactions)
        model.addAttribute("summary", transactionService.getSpendingSummary(id))
        model.addAttribute("totalIncome", totalIncome)
        model.addAttribute("totalExpense", totalExpense)
        model.addAttribute("categories", listOf("Salary","Food","Transport","Housing","Entertainment","Healthcare","Shopping","Other"))
        model.addAttribute("txTypes", Transaction.TransactionType.values())
        return "account"
    }

    @PostMapping("/transaction/add")
    fun addTransaction(
        @RequestParam accountId: Long,
        @RequestParam amount: Double,
        @RequestParam category: String,
        @RequestParam(defaultValue = "") description: String,
        @RequestParam type: Transaction.TransactionType,
        @RequestParam date: String
    ): String {
        transactionService.addTransaction(accountId, amount, category, description, type, date)
        return "redirect:/account/$accountId"
    }

    @PostMapping("/transaction/delete/{id}")
    fun deleteTransaction(@PathVariable id: Long, @RequestParam accountId: Long): String {
        txRepo.deleteById(id)
        return "redirect:/account/$accountId"
    }
}
EOF
echo "✅ WebController.kt created (Kotlin)"

# ── Patch AccountService.java — add findById ───
if ! grep -q "findById" src/main/java/com/financetracker/finance_tracker/service/AccountService.java; then
  # Insert findById before the last closing brace
  sed -i '' 's/^}$/    public Account findById(Long id) {\n        return accountRepo.findById(id)\n            .orElseThrow(() -> new RuntimeException("Account not found: " + id));\n    }\n}/' \
    src/main/java/com/financetracker/finance_tracker/service/AccountService.java
  echo "✅ findById added to AccountService.java"
else
  echo "✅ AccountService.java already has findById"
fi

# ── application.properties ─────────────────────
cat > src/main/resources/application.properties << 'EOF'
spring.datasource.url=jdbc:h2:mem:financedb
spring.datasource.driver-class-name=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=
spring.jpa.hibernate.ddl-auto=create-drop
spring.jpa.show-sql=false
spring.h2.console.enabled=true
spring.thymeleaf.cache=false
EOF

# ── setup.html ─────────────────────────────────
cat > src/main/resources/templates/setup.html << 'EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
  <meta charset="UTF-8"><title>FinTrack — Setup</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <style>
    body{background:linear-gradient(135deg,#1a1a2e,#16213e,#0f3460);min-height:100vh;display:flex;align-items:center;}
    .card{background:rgba(255,255,255,0.05);border:1px solid rgba(255,255,255,0.1);border-radius:20px;}
    .brand{font-size:2rem;font-weight:700;background:linear-gradient(90deg,#00d2ff,#7b2ff7);-webkit-background-clip:text;-webkit-text-fill-color:transparent;}
    .form-control{background:rgba(255,255,255,0.08);border:1px solid rgba(255,255,255,0.15);color:#fff;}
    .form-control:focus{background:rgba(255,255,255,0.12);border-color:#00d2ff;color:#fff;box-shadow:none;}
    .form-control::placeholder{color:rgba(255,255,255,0.3);}
    label{color:rgba(255,255,255,0.6);font-size:0.85rem;}
    .btn-go{background:linear-gradient(90deg,#00d2ff,#7b2ff7);border:none;padding:12px;font-weight:600;color:#fff;border-radius:50px;}
  </style>
</head>
<body>
<div class="container">
  <div class="row justify-content-center">
    <div class="col-md-4">
      <div class="card p-5 text-white text-center">
        <div class="brand mb-1">💰 FinTrack</div>
        <p style="color:rgba(255,255,255,0.4);" class="mb-4">Personal Finance Dashboard</p>
        <form th:action="@{/user/create}" method="post">
          <div class="mb-3 text-start">
            <label>Your Name</label>
            <input type="text" name="name" class="form-control mt-1" placeholder="Om Patil" required>
          </div>
          <div class="mb-4 text-start">
            <label>Email</label>
            <input type="email" name="email" class="form-control mt-1" placeholder="om@example.com" required>
          </div>
          <button type="submit" class="btn btn-go w-100">Get Started →</button>
        </form>
      </div>
    </div>
  </div>
</div>
</body>
</html>
EOF

# ── index.html ─────────────────────────────────
cat > src/main/resources/templates/index.html << 'EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
  <meta charset="UTF-8"><title>FinTrack — Dashboard</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <style>
    body{background:#0d1117;color:#e6edf3;font-family:-apple-system,sans-serif;}
    .navbar{background:#161b22;border-bottom:1px solid #30363d;}
    .brand{font-weight:700;font-size:1.3rem;color:#58a6ff;}
    .stat-card{background:#161b22;border:1px solid #30363d;border-radius:12px;padding:1.5rem;}
    .lbl{font-size:.75rem;color:#8b949e;text-transform:uppercase;letter-spacing:.05em;margin-bottom:4px;}
    .val{font-size:2rem;font-weight:700;}
    .green{color:#3fb950;}.red{color:#f85149;}
    .acc-card{background:#161b22;border:1px solid #30363d;border-radius:12px;padding:1.5rem;text-decoration:none;color:inherit;display:block;transition:border-color .2s;}
    .acc-card:hover{border-color:#58a6ff;color:inherit;}
    .badge-c{background:rgba(88,166,255,.15);color:#58a6ff;border-radius:50px;padding:3px 12px;font-size:.8rem;}
    .badge-s{background:rgba(63,185,80,.15);color:#3fb950;border-radius:50px;padding:3px 12px;font-size:.8rem;}
    .badge-cr{background:rgba(248,81,73,.15);color:#f85149;border-radius:50px;padding:3px 12px;font-size:.8rem;}
    .btn-new{background:#238636;border:none;color:#fff;border-radius:8px;padding:8px 18px;}
    .btn-new:hover{background:#2ea043;color:#fff;}
    .modal-content{background:#161b22;border:1px solid #30363d;color:#e6edf3;}
    .form-control,.form-select{background:#0d1117;border:1px solid #30363d;color:#e6edf3;}
    .form-control:focus,.form-select:focus{background:#0d1117;border-color:#58a6ff;color:#e6edf3;box-shadow:none;}
    .form-label{color:#8b949e;font-size:.85rem;}
  </style>
</head>
<body>
<nav class="navbar px-4 py-3 d-flex justify-content-between">
  <span class="brand">💰 FinTrack</span>
  <span style="color:#8b949e;" th:text="'Welcome, ' + ${user.name}"></span>
</nav>
<div class="container py-4">
  <div class="row g-3 mb-4">
    <div class="col-md-4">
      <div class="stat-card">
        <div class="lbl">Total Balance</div>
        <div class="val" th:classappend="${totalBalance >= 0}?'green':'red'"
             th:text="'$' + ${#numbers.formatDecimal(totalBalance,1,2)}"></div>
      </div>
    </div>
    <div class="col-md-4">
      <div class="stat-card">
        <div class="lbl">Total Accounts</div>
        <div class="val" th:text="${#lists.size(accounts)}"></div>
      </div>
    </div>
    <div class="col-md-4">
      <div class="stat-card">
        <div class="lbl">Email</div>
        <div style="font-size:1rem;margin-top:8px;" th:text="${user.email}"></div>
      </div>
    </div>
  </div>
  <div class="d-flex justify-content-between align-items-center mb-3">
    <h5 class="mb-0">Accounts</h5>
    <button class="btn btn-new" data-bs-toggle="modal" data-bs-target="#newAccModal">+ New Account</button>
  </div>
  <div class="row g-3" th:if="${not #lists.isEmpty(accounts)}">
    <div class="col-md-4" th:each="acc : ${accounts}">
      <a th:href="@{/account/{id}(id=${acc.id})}" class="acc-card">
        <div class="d-flex justify-content-between align-items-start mb-3">
          <span style="font-weight:600;" th:text="${acc.name}"></span>
          <span th:class="${acc.type.name()=='CHECKING'}?'badge-c':(${acc.type.name()=='SAVINGS'}?'badge-s':'badge-cr')"
                th:text="${acc.type}"></span>
        </div>
        <div class="lbl">Balance</div>
        <div style="font-size:1.6rem;font-weight:700;"
             th:classappend="${acc.balance>=0}?'green':'red'"
             th:text="'$'+${#numbers.formatDecimal(acc.balance,1,2)}"></div>
        <div style="color:#8b949e;font-size:.8rem;margin-top:8px;">View transactions →</div>
      </a>
    </div>
  </div>
  <div th:if="${#lists.isEmpty(accounts)}" style="text-align:center;padding:3rem;color:#8b949e;">
    <div style="font-size:3rem;">🏦</div><p>No accounts yet. Create your first one!</p>
  </div>
</div>
<div class="modal fade" id="newAccModal" tabindex="-1">
  <div class="modal-dialog"><div class="modal-content p-4">
    <h5 class="mb-4">New Account</h5>
    <form th:action="@{/account/create}" method="post">
      <input type="hidden" name="userId" th:value="${user.id}">
      <div class="mb-3">
        <label class="form-label">Account Name</label>
        <input type="text" name="name" class="form-control" placeholder="e.g. Main Checking" required>
      </div>
      <div class="mb-4">
        <label class="form-label">Type</label>
        <select name="type" class="form-select">
          <option th:each="t : ${accountTypes}" th:value="${t}" th:text="${t}"></option>
        </select>
      </div>
      <div class="d-flex gap-2">
        <button type="submit" class="btn btn-new flex-grow-1">Create</button>
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
      </div>
    </form>
  </div></div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
EOF

# ── account.html ───────────────────────────────
cat > src/main/resources/templates/account.html << 'EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
  <meta charset="UTF-8"><title>Account Detail</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <style>
    body{background:#0d1117;color:#e6edf3;font-family:-apple-system,sans-serif;}
    .navbar{background:#161b22;border-bottom:1px solid #30363d;}
    .brand{font-weight:700;font-size:1.3rem;color:#58a6ff;}
    .back{color:#58a6ff;text-decoration:none;font-size:.9rem;}
    .back:hover{color:#79c0ff;}
    .card-dark{background:#161b22;border:1px solid #30363d;border-radius:12px;padding:1.5rem;}
    .lbl{font-size:.75rem;color:#8b949e;text-transform:uppercase;letter-spacing:.05em;margin-bottom:4px;}
    .green{color:#3fb950;}.red{color:#f85149;}
    .form-control,.form-select{background:#0d1117;border:1px solid #30363d;color:#e6edf3;}
    .form-control:focus,.form-select:focus{background:#0d1117;border-color:#58a6ff;color:#e6edf3;box-shadow:none;}
    .form-label{color:#8b949e;font-size:.85rem;}
    .btn-add{background:#238636;border:none;color:#fff;border-radius:8px;}
    .btn-add:hover{background:#2ea043;color:#fff;}
    .table{color:#e6edf3;}
    .table td,.table th{border-color:#30363d;padding:12px;}
    .table thead th{background:#0d1117;color:#8b949e;font-size:.75rem;text-transform:uppercase;}
    .bi{background:rgba(63,185,80,.15);color:#3fb950;border-radius:50px;padding:2px 10px;font-size:.8rem;}
    .be{background:rgba(248,81,73,.15);color:#f85149;border-radius:50px;padding:2px 10px;font-size:.8rem;}
    .progress{background:#30363d;height:6px;border-radius:3px;}
    .progress-bar{background:linear-gradient(90deg,#58a6ff,#7b2ff7);}
  </style>
</head>
<body>
<nav class="navbar px-4 py-3 d-flex justify-content-between">
  <span class="brand">💰 FinTrack</span>
  <a href="/" class="back">← Dashboard</a>
</nav>
<div class="container py-4">
  <div class="card-dark mb-4">
    <div class="d-flex justify-content-between align-items-start">
      <div>
        <div class="lbl">Account</div>
        <h3 th:text="${account.name}" class="mb-1"></h3>
        <span style="background:rgba(88,166,255,.15);color:#58a6ff;border-radius:50px;padding:3px 12px;font-size:.8rem;"
              th:text="${account.type}"></span>
      </div>
      <div class="text-end">
        <div class="lbl">Balance</div>
        <div style="font-size:2.5rem;font-weight:700;"
             th:classappend="${account.balance>=0}?'green':'red'"
             th:text="'$'+${#numbers.formatDecimal(account.balance,1,2)}"></div>
      </div>
    </div>
    <div class="row g-3 mt-2">
      <div class="col-6">
        <div class="lbl">Total Income</div>
        <div class="green" style="font-size:1.2rem;font-weight:600;"
             th:text="'+ $'+${#numbers.formatDecimal(totalIncome,1,2)}"></div>
      </div>
      <div class="col-6">
        <div class="lbl">Total Expenses</div>
        <div class="red" style="font-size:1.2rem;font-weight:600;"
             th:text="'- $'+${#numbers.formatDecimal(totalExpense,1,2)}"></div>
      </div>
    </div>
  </div>
  <div class="row g-4">
    <div class="col-md-4">
      <div class="card-dark">
        <h6 style="color:#8b949e;" class="mb-3">Add Transaction</h6>
        <form th:action="@{/transaction/add}" method="post">
          <input type="hidden" name="accountId" th:value="${account.id}">
          <div class="mb-3">
            <label class="form-label">Amount ($)</label>
            <input type="number" name="amount" step="0.01" min="0.01" class="form-control" placeholder="0.00" required>
          </div>
          <div class="mb-3">
            <label class="form-label">Type</label>
            <select name="type" class="form-select">
              <option th:each="t : ${txTypes}" th:value="${t}" th:text="${t}"></option>
            </select>
          </div>
          <div class="mb-3">
            <label class="form-label">Category</label>
            <select name="category" class="form-select">
              <option th:each="c : ${categories}" th:value="${c}" th:text="${c}"></option>
            </select>
          </div>
          <div class="mb-3">
            <label class="form-label">Description</label>
            <input type="text" name="description" class="form-control" placeholder="Optional">
          </div>
          <div class="mb-4">
            <label class="form-label">Date</label>
            <input type="date" name="date" class="form-control" required>
          </div>
          <button type="submit" class="btn btn-add w-100">Add Transaction</button>
        </form>
      </div>
      <div class="card-dark mt-4" th:if="${not #lists.isEmpty(summary)}">
        <h6 style="color:#8b949e;" class="mb-3">Spending by Category</h6>
        <div th:each="s : ${summary}" class="mb-3">
          <div class="d-flex justify-content-between mb-1">
            <span style="font-size:.9rem;" th:text="${s.category}"></span>
            <span class="red" style="font-size:.9rem;" th:text="'$'+${#numbers.formatDecimal(s.total,1,2)}"></span>
          </div>
          <div class="progress">
            <div class="progress-bar"
                 th:style="'width:' + (${totalExpense > 0} ? ${#numbers.formatDecimal(s.total / totalExpense * 100,1,0)} : '0') + '%'"></div>
          </div>
        </div>
      </div>
    </div>
    <div class="col-md-8">
      <div class="card-dark">
        <h6 style="color:#8b949e;" class="mb-3">Transactions</h6>
        <div th:if="${#lists.isEmpty(transactions)}"
             style="text-align:center;padding:2rem;color:#8b949e;">No transactions yet.</div>
        <div th:if="${not #lists.isEmpty(transactions)}" style="overflow-x:auto;">
          <table class="table table-borderless">
            <thead><tr>
              <th>Date</th><th>Category</th><th>Description</th>
              <th class="text-end">Amount</th><th></th>
            </tr></thead>
            <tbody>
              <tr th:each="tx : ${transactions}">
                <td style="color:#8b949e;font-size:.85rem;" th:text="${tx.date}"></td>
                <td><span th:class="${tx.type.name()=='INCOME'}?'bi':'be'" th:text="${tx.category}"></span></td>
                <td style="color:#8b949e;font-size:.9rem;" th:text="${tx.description}"></td>
                <td class="text-end" style="font-weight:600;"
                    th:classappend="${tx.type.name()=='INCOME'}?'green':'red'"
                    th:text="${tx.type.name()=='INCOME'} ? ('+ $'+${#numbers.formatDecimal(tx.amount,1,2)}) : ('- $'+${#numbers.formatDecimal(tx.amount,1,2)})">
                </td>
                <td>
                  <form th:action="@{/transaction/delete/{id}(id=${tx.id})}" method="post" style="display:inline;">
                    <input type="hidden" name="accountId" th:value="${account.id}">
                    <button type="submit" style="background:none;border:none;color:#f85149;cursor:pointer;">✕</button>
                  </form>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
EOF

echo ""
echo "✅ All done! Run the app with:"
echo "   mvn spring-boot:run"
echo "   Then open: http://localhost:8080"
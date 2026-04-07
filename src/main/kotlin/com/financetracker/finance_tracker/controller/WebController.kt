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

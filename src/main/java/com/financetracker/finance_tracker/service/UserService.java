package com.financetracker.finance_tracker.service;

import com.financetracker.finance_tracker.model.User;
import com.financetracker.finance_tracker.repository.UserRepository;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class UserService {

    private final UserRepository userRepo;

    public UserService(UserRepository userRepo) {
        this.userRepo = userRepo;
    }

    public User create(String name, String email) {
        User u = new User();
        u.setName(name);
        u.setEmail(email);
        return userRepo.save(u);
    }

    public User findById(Long id) {
        return userRepo.findById(id)
            .orElseThrow(() -> new RuntimeException("User not found: " + id));
    }

    public List<User> findAll() {
        return userRepo.findAll();
    }
}
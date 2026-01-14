using System.ComponentModel.DataAnnotations;

namespace MyMoneyApi.Models;

public class Transaction
{
    public string Id { get; set; } = Guid.NewGuid().ToString();
    
    [Required]
    public string Title { get; set; } = string.Empty;
    
    [Required]
    public decimal Amount { get; set; }
    
    [Required]
    public string Category { get; set; } = string.Empty;
    
    public DateTime Date { get; set; } = DateTime.UtcNow;
    
    [Required]
    public TransactionType Type { get; set; }
    
    public string? Description { get; set; }
    
    public string? UserId { get; set; }
    public string? DeviceId { get; set; }
    public bool IsSynced { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}

public enum TransactionType
{
    Income = 0,
    Expense = 1
}
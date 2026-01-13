using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MyMoneyApi.Data;
using MyMoneyApi.Models;

namespace MyMoneyApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class TransactionsController : ControllerBase
{
    private readonly MyMoneyDbContext _context;

    public TransactionsController(MyMoneyDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<Transaction>>> GetTransactions()
    {
        return await _context.Transactions.OrderByDescending(t => t.Date).ToListAsync();
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<Transaction>> GetTransaction(string id)
    {
        var transaction = await _context.Transactions.FindAsync(id);
        return transaction == null ? NotFound() : transaction;
    }

    [HttpPost]
    public async Task<ActionResult<Transaction>> PostTransaction(Transaction transaction)
    {
        _context.Transactions.Add(transaction);
        await _context.SaveChangesAsync();
        return CreatedAtAction(nameof(GetTransaction), new { id = transaction.Id }, transaction);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> PutTransaction(string id, Transaction transaction)
    {
        if (id != transaction.Id) return BadRequest();

        _context.Entry(transaction).State = EntityState.Modified;
        await _context.SaveChangesAsync();
        return NoContent();
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteTransaction(string id)
    {
        var transaction = await _context.Transactions.FindAsync(id);
        if (transaction == null) return NotFound();

        _context.Transactions.Remove(transaction);
        await _context.SaveChangesAsync();
        return NoContent();
    }
}
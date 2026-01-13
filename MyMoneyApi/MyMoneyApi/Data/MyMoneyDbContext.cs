using Microsoft.EntityFrameworkCore;
using MyMoneyApi.Models;

namespace MyMoneyApi.Data;

public class MyMoneyDbContext : DbContext
{
    public MyMoneyDbContext(DbContextOptions<MyMoneyDbContext> options) : base(options) { }

    public DbSet<Transaction> Transactions { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Transaction>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Amount).HasColumnType("decimal(18,2)");
            entity.Property(e => e.Type).HasConversion<int>();
        });
    }
}
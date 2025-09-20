<?php
class ReportApp {
    private array $orders;
    private string $file;
    private string $logFile;
    private array $validOrders = [];
    private int $totalPaid = 0;
    private int $count = 0;
    private float $avg = 0.0;

    public function __construct(array $orders, string $file, string $logFile = "report.log") {
        $this->orders = $orders;
        $this->file = $file;
        $this->logFile = $logFile;

        $this->log("Start report");
        echo "Start report\n";
    }

    public function process(): void {
        try {
            foreach ($this->orders as $o) {
                if ($o['status'] === 'paid' && $o['amount'] > 0) {
                    $this->validOrders[] = $o;
                    $this->totalPaid += $o['amount'];
                } elseif ($o['status'] === 'paid' && $o['amount'] <= 0) {
                    $this->log("Invalid amount detected for order ID {$o['id']}: {$o['amount']}");
                }
            }

            $this->count = count($this->validOrders);
            $this->avg = $this->count > 0 ? $this->totalPaid / $this->count : 0;

            echo "Valid orders: {$this->count}\n";
            echo "Total paid: {$this->totalPaid}\n";
            echo "Avg amount: {$this->avg}\n";

            $this->log("Processing complete: {$this->count} valid orders, total {$this->totalPaid}, avg {$this->avg}");
        } catch (\Exception $e) {
            $this->log("Error during processing: " . $e->getMessage());
            throw $e;
        }
    }

    public function write(): void {
        try {
            $txt = $this->summary();
            $tmpFile = $this->file . '.tmp';

            if (file_put_contents($tmpFile, $txt, LOCK_EX) === false) {
                throw new RuntimeException("Failed to write report to $tmpFile");
            }

            rename($tmpFile, $this->file);
            echo "Report saved to {$this->file}\n";
            $this->log("Report saved successfully to {$this->file}");
        } catch (\Exception $e) {
            $this->log("Error writing report: " . $e->getMessage());
            throw $e;
        }
    }

    public function summary(): string {
        return "Valid orders: {$this->count}" . PHP_EOL .
            "Total paid: {$this->totalPaid}" . PHP_EOL .
            "Avg amount: {$this->avg}" . PHP_EOL;
    }

    private function log(string $message): void {
        $timestamp = date('Y-m-d H:i:s');
        file_put_contents($this->logFile, "[$timestamp] $message" . PHP_EOL, FILE_APPEND | LOCK_EX);
    }

    public function __destruct() {
        $this->log("ReportApp destructed");
    }
}

// Дані
$orders = [
    ["id"=>1, "user"=>"Ivan", "amount"=>100, "status"=>"paid"],
    ["id"=>2, "user"=>"Oksana", "amount"=>-50, "status"=>"paid"], // аномалія
    ["id"=>3, "user"=>"Ivan", "amount"=>200, "status"=>"pending"], // не враховується
    ["id"=>4, "user"=>"Petro", "amount"=>300, "status"=>"paid"],
];

// Використання
$app = new ReportApp($orders, "report.txt");
$app->process();
$app->write();

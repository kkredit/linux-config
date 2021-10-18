package main

import (
	"context"
	"fmt"
	"os"
	"os/signal"
	"sync"
	"time"
)

func main() {
	parentCtx, stop := signal.NotifyContext(context.Background(), os.Interrupt)
	ctx, cancel := context.WithTimeout(parentCtx, 5*time.Second)
	go func() {
		select {
		case <-parentCtx.Done():
			stop()
			fmt.Println("Shutting down...")
			cancel()
		}
	}()

	fmt.Println("Starting workers...")
	var wg sync.WaitGroup
	for i := 0; i < 3; i++ {
		wg.Add(1)
		go worker(context.WithValue(ctx, "number", i), &wg)
	}

	fmt.Println("Waiting for workers to finish...")
	wg.Wait()
	fmt.Println("Workers finished")
}

func worker(ctx context.Context, wg *sync.WaitGroup) {
	defer wg.Done()
	for {
		select {
		case <-ctx.Done():
			return
		default:
			work(ctx.Value("number").(int))
		}
	}
}

func work(number int) {
	fmt.Printf("Worker %d working...\n", number)
	time.Sleep(1 * time.Second)
}

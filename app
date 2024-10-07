import tkinter as tk
import random

class Game2048:
    def __init__(self, root):
        self.root = root
        self.root.title('2048 Game')
        self.root.geometry('1000x1200')
        #self.root.state('zoomed')
        self.root.resizable(True, True)
        
        self.grid_color = '#bbada0'
        self.tile_color = { 
            0: '#cdc1b4', 2: '#eee4da', 4: '#ede0c8', 8: '#f2b179', 
            16: '#f59563', 32: '#f67c5f', 64: '#f65e3b', 128: '#edcf72', 
            256: '#edcc61', 512: '#edc850', 1024: '#edc53f', 2048: '#edc22e' 
        }
        self.text_color = {
            2: '#776e65', 4: '#776e65', 8: '#f9f6f2', 16: '#f9f6f2', 
            32: '#f9f6f2', 64: '#f9f6f2', 128: '#f9f6f2', 256: '#f9f6f2', 
            512: '#f9f6f2', 1024: '#f9f6f2', 2048: '#f9f6f2'
        }
        self.font = ('Verdana', 24, 'bold')
        self.board = [[0]*4 for _ in range(4)]
        self.score = 0
        self.create_GUI()
        self.start_game()
        self.root.bind('<Up>', self.move_up)
        self.root.bind('<Down>', self.move_down)
        self.root.bind('<Left>', self.move_left)
        self.root.bind('<Right>', self.move_right)

    def create_GUI(self):
        self.main_grid = tk.Frame(self.root, bg=self.grid_color, bd=3, width=1000, height=1000)
        self.main_grid.place(relx=0.5, rely=0.5, anchor="center",bordermode='outside')
        
        self.cells = []
        for i in range(4):
            row = []
            for j in range(4):
                cell_frame = tk.Frame(
                    self.main_grid, bg=self.tile_color[0], width=100, height=100
                )
                cell_frame.grid(row=i, column=j, padx=5, pady=5)
                cell_number = tk.Label(self.main_grid, text='', bg=self.tile_color[0], font=self.font, width=4, height=2)
                cell_number.grid(row=i, column=j)
                row.append(cell_number)
            self.cells.append(row)

        # Create Scoreboard
        self.score_frame = tk.Frame(self.root)
        self.score_frame.place(relx=0.5, y=40, anchor="center")
        tk.Label(self.score_frame, text="Score", font=("Arial", 16)).grid(row=0)
        self.score_label = tk.Label(self.score_frame, text=str(self.score), font=("Arial", 20))
        self.score_label.grid(row=1)

    def start_game(self):
        # Populate two random cells to start the game
        self.add_random_tile()
        self.add_random_tile()
        self.update_GUI()

    def add_random_tile(self):
        empty_cells = [(i, j) for i in range(4) for j in range(4) if self.board[i][j] == 0]
        if empty_cells:
            i, j = random.choice(empty_cells)
            self.board[i][j] = random.choice([2, 4])

    def update_GUI(self):
        for i in range(4):
            for j in range(4):
                tile_value = self.board[i][j]
                self.cells[i][j].configure(
                    text=str(tile_value) if tile_value != 0 else '',
                    bg=self.tile_color[tile_value],
                    fg=self.text_color[tile_value] if tile_value in self.text_color else 'black'
                )
        self.score_label.configure(text=str(self.score))
        self.root.update_idletasks()

    def compress(self, grid):
        new_grid = [[0] * 4 for _ in range(4)]
        for i in range(4):
            pos = 0
            for j in range(4):
                if grid[i][j] != 0:
                    new_grid[i][pos] = grid[i][j]
                    pos += 1
        return new_grid

    def merge(self, grid):
        for i in range(4):
            for j in range(3):
                if grid[i][j] == grid[i][j + 1] and grid[i][j] != 0:
                    grid[i][j] *= 2
                    grid[i][j + 1] = 0
                    self.score += grid[i][j]
        return grid

    def reverse(self, grid):
        new_grid = []
        for i in range(4):
            new_grid.append(list(reversed(grid[i])))
        return new_grid

    def transpose(self, grid):
        new_grid = [[0]*4 for _ in range(4)]
        for i in range(4):
            for j in range(4):
                new_grid[i][j] = grid[j][i]
        return new_grid

    def move_up(self, event):
        self.board = self.transpose(self.board)
        self.board = self.compress(self.board)
        self.board = self.merge(self.board)
        self.board = self.compress(self.board)
        self.board = self.transpose(self.board)
        self.add_random_tile()
        self.update_GUI()
        self.check_game_over()

    def move_down(self, event):
        self.board = self.transpose(self.board)
        self.board = self.reverse(self.board)
        self.board = self.compress(self.board)
        self.board = self.merge(self.board)
        self.board = self.compress(self.board)
        self.board = self.reverse(self.board)
        self.board = self.transpose(self.board)
        self.add_random_tile()
        self.update_GUI()
        self.check_game_over()

    def move_left(self, event):
        self.board = self.compress(self.board)
        self.board = self.merge(self.board)
        self.board = self.compress(self.board)
        self.add_random_tile()
        self.update_GUI()
        self.check_game_over()

    def move_right(self, event):
        self.board = self.reverse(self.board)
        self.board = self.compress(self.board)
        self.board = self.merge(self.board)
        self.board = self.compress(self.board)
        self.board = self.reverse(self.board)
        self.add_random_tile()
        self.update_GUI()
        self.check_game_over()

    def check_game_over(self):
        if any(2048 in row for row in self.board):
            self.display_game_over(True)
        elif not any(0 in row for row in self.board):
            for i in range(4):
                for j in range(3):
                    if self.board[i][j] == self.board[i][j + 1]:
                        return
            for i in range(3):
                for j in range(4):
                    if self.board[i][j] == self.board[i + 1][j]:
                        return
            self.display_game_over(False)

    def display_game_over(self, won):
        message = "You win!" if won else "Game over!"
        game_over_frame = tk.Frame(self.main_grid, borderwidth=2)
        game_over_frame.place(relx=0.5, rely=0.5, anchor="center")
        tk.Label(
            game_over_frame, text=message, bg="#ffcc00", fg="#f9f6f2", font=("Verdana", 24, "bold")
        ).pack()
        self.root.update_idletasks()

if __name__ == "__main__":
    root = tk.Tk()
    game = Game2048(root)
    root.mainloop()

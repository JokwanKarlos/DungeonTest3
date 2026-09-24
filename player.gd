class_name Player
extends Node2D

var grid_position: Vector2i
var hp: int = 10
var damage: int = 2

func move(direction: Vector2i):
	grid_position += direction

func attack(enemy):
	enemy.take_damage(damage)
	print("Player attacks ", enemy.id, " for ", damage, " damage!")

func take_damage(amount: int):
	hp -= amount

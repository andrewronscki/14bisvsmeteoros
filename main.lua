LARGURA_TELA = 320
ALTURA_TELA = 480
MAX_METEOROS = 12
FIM_JOGO = false
METEOROS_ATINGIDOS = 0
NUMERO_METEOROS_OBJETIVO = 100

Aviao_14bis = {
	src = "imagens/14bis.png",
	largura = 55,
	altura = 63,
	x = LARGURA_TELA/2 - 64/2,
	y = ALTURA_TELA - 64,
	tiros = {}
}

Meteoros = {}

function DarTiro()
	Disparo:play()
	
	local tiro = {
		x = Aviao_14bis.x + Aviao_14bis.largura/2,
		y = Aviao_14bis.y,
		largura = 16,
		altura = 16
	}

	table.insert(Aviao_14bis.tiros, tiro)
end

function MoveTiros()
	for i = #Aviao_14bis.tiros, 1, -1 do
		if Aviao_14bis.tiros[i].y > 0 then
			Aviao_14bis.tiros[i].y = Aviao_14bis.tiros[i].y - 1
		else
			table.remove(Aviao_14bis.tiros, i)
		end
	end
end

function DestroiAviao()
	Destruicao:play()

	Aviao_14bis.src = "imagens/explosao_nave.png"
	Aviao_14bis.imagem = love.graphics.newImage(Aviao_14bis.src)
	Aviao_14bis.largura = 67
	Aviao_14bis.altura = 77
	
end

function TemColisao(x1, y1, l1, a1, x2, y2, l2, a2)
	return x2 < x1 + l1 and
		x1 < x2 + l2 and
		y1 < y2 + a2 and
		y2 < y1 + 1
end

function RemoveMeteoros()
	for i = #Meteoros, 1, -1 do
		if Meteoros[i].y > ALTURA_TELA then
			table.remove(Meteoros, i)
		end
	end
end

function CriaMeteoro()
	Meteoro = {
		x = math.random(LARGURA_TELA),
		y = -70,
		largura = 50,
		altura = 44,
		peso = math.random(3),
		deslocamento_horizontal = math.random(-1, 1)
	}
	table.insert(Meteoros, Meteoro)
end

function MoveMeteoros()
	for key, value in pairs(Meteoros) do
		value.y = value.y + value.peso
		value.x = value.x + value.deslocamento_horizontal
	end
end

function Move14bis()
	if love.keyboard.isDown('w') then
		Aviao_14bis.y = Aviao_14bis.y - 4
	end
	if love.keyboard.isDown('s') then
		Aviao_14bis.y = Aviao_14bis.y + 4
	end
	if love.keyboard.isDown('a') then
		Aviao_14bis.x = Aviao_14bis.x - 4
	end
	if love.keyboard.isDown('d') then
		Aviao_14bis.x = Aviao_14bis.x + 4
	end
end

function TrocaMusicaDeFundo()
	Musica_ambiente:stop()
	Game_over:play()

end

function ChecaColisaoComAviao()
	for key, value in pairs(Meteoros) do
		if TemColisao(value.x, value.y, value.largura, value.altura,
		Aviao_14bis.x, Aviao_14bis.y, Aviao_14bis.largura, 
		Aviao_14bis.altura) then
			TrocaMusicaDeFundo()
			DestroiAviao()
			FIM_JOGO = true
		end
	end
end

function ChecaColisaoComTiros()
	for i = #Aviao_14bis.tiros, 1, -1 do
		for j = #Meteoros, 1, -1 do
			if TemColisao(Aviao_14bis.tiros[i].x, Aviao_14bis.tiros[i].y, Aviao_14bis.tiros[i].largura,
			Aviao_14bis.tiros[i].altura, Meteoros[j].x, Meteoros[j].y, Meteoros[j].largura,
			Meteoros[j].altura) then
				METEOROS_ATINGIDOS = METEOROS_ATINGIDOS + 1
				table.remove(Aviao_14bis.tiros, i)
				table.remove(Meteoros, j)
				break
			end
		end
	end
end

function ChecaColisoes()
	ChecaColisaoComAviao()
	ChecaColisaoComTiros()
end

function ChecaObjetivoConcluido()
	if METEOROS_ATINGIDOS >= NUMERO_METEOROS_OBJETIVO then
		VENCEDOR = true
		Musica_ambiente:stop()
		Vencedor:play()
	end
end

function love.load()
	love.window.setMode(LARGURA_TELA, ALTURA_TELA, { resizable = false })
	love.window.setTitle("14bis vs Meteoros")

	math.randomseed(os.time())

	Background = love.graphics.newImage("imagens/background.png")
	Aviao_14bis.imagem = love.graphics.newImage(Aviao_14bis.src)
	Meteoro_img = love.graphics.newImage("imagens/meteoro.png")
	Tiro_img = love.graphics.newImage("imagens/tiro.png")
	Gameover_img = love.graphics.newImage("imagens/gameover.png")
	Vencedor_img = love.graphics.newImage("imagens/vencedor.png")

	Musica_ambiente = love.audio.newSource("audios/ambiente.wav", "static")
	Musica_ambiente:setLooping(true)
	Musica_ambiente:play()

	Destruicao = love.audio.newSource("audios/destruicao.wav", "static")
	Game_over = love.audio.newSource("audios/game_over.wav", "static")
	Disparo = love.audio.newSource("audios/disparo.wav", "static")
	Vencedor = love.audio.newSource("audios/vencedor.wav", "static")
end

function love.update(dt)
	if not FIM_JOGO and not VENCEDOR then
		if love.keyboard.isDown('w', 'a', 's', 'd') then
			Move14bis()
		end
		RemoveMeteoros()
		if #Meteoros < MAX_METEOROS then
			CriaMeteoro()
		end
		MoveMeteoros()
		MoveTiros()
		ChecaColisoes()
		ChecaObjetivoConcluido()
	end
end

function love.keypressed(tecla)
	if tecla == 'escape' then
		love.event.quit()

	elseif tecla == 'space' then
		DarTiro()
	end

end

function love.draw()
	love.graphics.draw(Background, 0, 0)

	love.graphics.draw(Aviao_14bis.imagem, Aviao_14bis.x, Aviao_14bis.y)

	love.graphics.print("Meteoros restantes "..NUMERO_METEOROS_OBJETIVO - METEOROS_ATINGIDOS, 0, 0) 

	for key, value in pairs(Meteoros) do
		love.graphics.draw(Meteoro_img,  value.x, value.y)
	end

	for key, value in pairs(Aviao_14bis.tiros) do
		love.graphics.draw(Tiro_img,  value.x, value.y)
	end

	if FIM_JOGO then
		love.graphics.draw(Gameover_img, LARGURA_TELA/2 - Gameover_img:getWidth()/2, ALTURA_TELA/2 - Gameover_img:getHeight()/2)
	end

	if VENCEDOR then
		love.graphics.draw(Vencedor_img, LARGURA_TELA/2 - Vencedor_img:getWidth()/2, ALTURA_TELA/2 - Vencedor_img:getHeight()/2)
	end
end
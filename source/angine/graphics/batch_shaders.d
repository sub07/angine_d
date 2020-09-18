module angine.graphics.batch_shaders;

immutable vTex = `
#version 460

layout(location = 0) in vec2 vertexPosition;
layout(location = 1) in vec2 texturePosition;
layout(location = 2) in vec4 color;

out vec2 texPos;
out vec4 tint;
uniform vec2 viewportSize;

void main() {
	vec2 workingVec = vec2(int(vertexPosition.x), int(vertexPosition.y));
	workingVec.x = workingVec.x * (2.0 / viewportSize.x) - 1.0;
	workingVec.y = workingVec.y * -(2.0 / viewportSize.y) + 1.0;
	gl_Position = vec4(workingVec, 0.0, 1.0);
	texPos = texturePosition;
	tint = color;
}
`;

immutable fTex = `
#version 460

in vec2 texPos;
in vec4 tint;
uniform sampler2D textureUnit;
out vec4 finalPixelColor;

void main() {
    finalPixelColor = texture(textureUnit, texPos) * tint;
}
`;

immutable fText = `
#version 460

in vec2 texPos;
in vec4 tint;
uniform sampler2D textureUnit;
out vec4 finalPixelColor;

void main() {
    finalPixelColor = vec4(1, 1, 1, texture(textureUnit, texPos).r) * tint;
}
`;
<?php

namespace Tests\Unit;

use App\ExampleHandler;

test('example handler', function () {
    assertTrue(class_exists(ExampleHandler::class));

    $handler = new ExampleHandler();
    assertIsString($handler->foo());
    assertEquals('bar', $handler->foo());
});

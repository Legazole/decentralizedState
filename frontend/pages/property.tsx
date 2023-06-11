import React from 'react';
import { Container, Image, ImageContainer } from '../styles/pages/property';
import { Button } from "@taikai/rocket-kit";

export default function Property() {
  return (
    <Container>
      <ImageContainer>
        <Image src="/sea_view.png" alt="" />
      </ImageContainer>
    </Container>
  );
}
